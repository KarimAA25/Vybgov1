// ignore_for_file: depend_on_referenced_packages

import 'dart:developer' as developer;

import 'package:admin/app/constant/collection_name.dart';
import 'package:admin/app/constant/constants.dart';
import 'package:admin/app/constant/show_toast.dart';
import 'package:admin/app/models/admin_commission_model.dart';
import 'package:admin/app/models/admin_model.dart';
import 'package:admin/app/models/banner_model.dart';
import 'package:admin/app/models/booking_model.dart';
import 'package:admin/app/models/brand_model.dart';
import 'package:admin/app/models/cancellation_charge_model.dart';
import 'package:admin/app/models/constant_model.dart';
import 'package:admin/app/models/contact_us_model.dart';
import 'package:admin/app/models/coupon_model.dart';
import 'package:admin/app/models/currency_model.dart';
import 'package:admin/app/models/documents_model.dart';
import 'package:admin/app/models/driver_user_model.dart';
import 'package:admin/app/models/email_template_model.dart';
import 'package:admin/app/models/emergency_number_model.dart';
import 'package:admin/app/models/global_value_model.dart';
import 'package:admin/app/models/intercity_model.dart';
import 'package:admin/app/models/language_model.dart';
import 'package:admin/app/models/loyalty_point_transaction_model.dart';
import 'package:admin/app/models/model_vehicle_model.dart';
import 'package:admin/app/models/notification_model.dart';
import 'package:admin/app/models/push_notification_model.dart';
import 'package:admin/app/models/onBoarding_model.dart';
import 'package:admin/app/models/parcel_model.dart';
import 'package:admin/app/models/payment_method_model.dart';
import 'package:admin/app/models/payout_request_model.dart';
import 'package:admin/app/models/rental_booking_model.dart';
import 'package:admin/app/models/smtp_setting_model.dart';
import 'package:admin/app/models/subscription_model.dart';
import 'package:admin/app/models/subscription_plan_history.dart';
import 'package:admin/app/models/support_reason_model.dart';
import 'package:admin/app/models/support_ticket_model.dart';
import 'package:admin/app/models/tax_model.dart';
import 'package:admin/app/models/user_model.dart';
import 'package:admin/app/models/vehicle_type_model.dart';
import 'package:admin/app/models/wallet_transaction_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/rental_package_model.dart';
import '../models/zone_model.dart';

class FireStoreUtils {
  static final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static String? getCurrentUid() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  static Future<bool> userExistOrNot(String uid) async {
    bool isExist = false;
    try {
      await fireStore.collection(CollectionName.admin).doc(uid).get().then(
        (value) {
          if (value.exists) {
            Constant.adminModel = AdminModel.fromJson(value.data()!);
            isExist = true;
          }
        },
      );
    } catch (e, stack) {
      developer.log("Error checking if user exists", error: e, stackTrace: stack);
    }
    return isExist;
  }

  static Future<bool> isLogin() async {
    bool isLogin = false;
    if (FirebaseAuth.instance.currentUser != null) {
      isLogin = await userExistOrNot(FirebaseAuth.instance.currentUser!.uid);
    } else {
      isLogin = false;
    }
    return isLogin;
  }

  static Future<void> getSettings() async {
    final settingsRef = fireStore.collection(CollectionName.settings);
    final constantDoc = await settingsRef.doc("constant").get();
    if (constantDoc.exists) {
      final data = constantDoc.data()!;
      Constant.appColor = data["appColor"];
      Constant.appName = data["appName"];
      Constant.minimumAmountToDeposit = data["minimum_amount_deposit"];
      Constant.minimumAmountToWithdrawal = data["minimum_amount_withdraw"];
      Constant.notificationServerKey = data["notification_senderId"] ?? "";
      Constant.jsonFileURL = data["jsonFileURL"];
      Constant.sosAlertNumber = data["sosNumber"];
      Constant.countryCode = data["countryCode"] ?? "+91";
      final mapSettings = data["mapSettings"] as Map<String, dynamic>?;

      if (mapSettings != null) {
        Constant.googleMapKey = mapSettings["googleMapKey"] ?? "";
        Constant.selectedMap = mapSettings["mapType"] ?? "Google Map";
      }
    }

    final adminCommissionDoc = await settingsRef.doc("admin_commission").get();
    if (adminCommissionDoc.exists && adminCommissionDoc.data() != null) {
      Constant.adminCommission = AdminCommission.fromJson(adminCommissionDoc.data()!);
    }

    await fireStore.collection(CollectionName.settings).doc("globalValue").get().then((value) {
      if (value.exists) {
        Constant.distanceType = value.data()!["distanceType"];
        log("Type:::::::::::${Constant.distanceType}");
      }
    });
  }

  static Future<CurrencyModel?> getCurrency() async {
    CurrencyModel? currencyModel;
    final query = await fireStore.collection(CollectionName.currencies).where("active", isEqualTo: true).limit(1).get();
    if (query.docs.isNotEmpty) {
      currencyModel = CurrencyModel.fromJson(query.docs.first.data());
    }
    return currencyModel;
  }

  static Future<int> countUsers() async {
    final userList = FirebaseFirestore.instance.collection(CollectionName.users);
    final query = await userList.count().get();
    Constant.usersLength = query.count ?? 0;
    return query.count ?? 0;
  }

  static Future<int> countSearchUsers(String searchQuery, String searchType) async {
    final queryLower = searchQuery.trim().toLowerCase();

    Query<Map<String, dynamic>> userList;

    if (searchType == "email") {
      userList = FirebaseFirestore.instance.collection(CollectionName.users).where("searchEmailKeywords", arrayContains: queryLower);
    } else if (searchType == "slug") {
      userList = FirebaseFirestore.instance.collection(CollectionName.users).where("searchNameKeywords", arrayContains: queryLower);
    } else if (searchType == "phoneNumber") {
      userList = FirebaseFirestore.instance
          .collection(CollectionName.users)
          .where("phoneNumber", isGreaterThanOrEqualTo: queryLower)
          .where("phoneNumber", isLessThanOrEqualTo: "$queryLower\uf8ff");
    } else {
      userList = FirebaseFirestore.instance.collection(CollectionName.users);
    }

    final AggregateQuerySnapshot query = await userList.count().get();
    Constant.usersLength = query.count ?? 0;

    return query.count ?? 0;
  }

  static Future<List<UserModel>> getUsers(int pageNumber, int pageSize, String searchQuery, String searchType) async {
    List<UserModel> userList = [];
    DocumentSnapshot? lastDocument;

    try {
      final collection = FirebaseFirestore.instance.collection(CollectionName.users);
      final queryLower = searchQuery.trim().toLowerCase();

      Query<Map<String, dynamic>> query;

      if (queryLower.isNotEmpty) {
        if (searchType == "email") {
          query = collection.where("searchEmailKeywords", arrayContains: queryLower).orderBy('createdAt', descending: true);
        } else if (searchType == "slug") {
          query = collection.where("searchNameKeywords", arrayContains: queryLower).orderBy('createdAt', descending: true);
        } else if (searchType == "phoneNumber") {
          query = collection
              .where("phoneNumber", isGreaterThanOrEqualTo: queryLower)
              .where("phoneNumber", isLessThanOrEqualTo: "$queryLower\uf8ff")
              .orderBy('createdAt', descending: true);
        } else {
          query = collection.orderBy('createdAt', descending: true);
        }
      } else {
        query = collection.orderBy('createdAt', descending: true);
      }

      // Pagination
      if (pageNumber > 1) {
        final previousDocs = await query.limit(pageSize * (pageNumber - 1)).get();
        if (previousDocs.docs.isNotEmpty) {
          lastDocument = previousDocs.docs.last;
        }
      }

      final finalQuery = lastDocument != null ? query.startAfterDocument(lastDocument) : query;

      final result = await finalQuery.limit(pageSize).get();

      userList = result.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
    } catch (error) {
      log("get Users  error: $error");
    }

    return userList;
  }

  static Future<List<UserModel>> getRecentUsers() async {
    List<UserModel> usersModelList = [];
    try {
      final snapshot = await fireStore.collection(CollectionName.users).orderBy('createdAt', descending: true).limit(5).get();
      for (var doc in snapshot.docs) {
        usersModelList.add(UserModel.fromJson(doc.data()));
      }
    } catch (error) {
      log(error.toString());
    }
    return usersModelList;
  }

  static Future<int> countDrivers() async {
    final userList = FirebaseFirestore.instance.collection(CollectionName.drivers);
    final query = await userList.count().get();
    Constant.driverLength = query.count ?? 0;
    return query.count ?? 0;
  }

  static Future<int> countUnVerifiedDriver() async {
    int count = 0;

    final snapshot = await FirebaseFirestore.instance.collection(CollectionName.drivers).where('isVerified', isEqualTo: false).get();

    for (var doc in snapshot.docs) {
      final driver = DriverUserModel.fromJson(doc.data());

      if (driver.verifyDocument != null && driver.verifyDocument!.isNotEmpty) {
        count++;
      }
    }

    Constant.unVerifiedDriverLength = count;
    return count;
  }

  static Future<int> countVerifiedDriver() async {
    final userList = FirebaseFirestore.instance.collection(CollectionName.drivers).where('isVerified', isEqualTo: true);
    final query = await userList.count().get();
    Constant.verifiedDriverLength = query.count ?? 0;
    return query.count ?? 0;
  }

  static Future<int> countSearchDrivers(String searchQuery, String searchType) async {
    final queryLower = searchQuery.trim().toLowerCase();

    Query<Map<String, dynamic>> userList;

    if (searchType == "email") {
      userList = FirebaseFirestore.instance.collection(CollectionName.drivers).where("searchEmailKeywords", arrayContains: queryLower);
    } else if (searchType == "slug") {
      userList = FirebaseFirestore.instance.collection(CollectionName.drivers).where("searchNameKeywords", arrayContains: queryLower);
    } else if (searchType == "phoneNumber") {
      userList = FirebaseFirestore.instance
          .collection(CollectionName.drivers)
          .where("phoneNumber", isGreaterThanOrEqualTo: queryLower)
          .where("phoneNumber", isLessThanOrEqualTo: "$queryLower\uf8ff");
    } else {
      userList = FirebaseFirestore.instance.collection(CollectionName.drivers);
    }

    final AggregateQuerySnapshot query = await userList.count().get();
    Constant.driverLength = query.count ?? 0;

    return query.count ?? 0;
  }

  static Future<List<DriverUserModel>> getDriver(int pageNumber, int pageSize, String searchQuery, String searchType) async {
    List<DriverUserModel> driverList = [];
    DocumentSnapshot? lastDocument;

    try {
      final collection = FirebaseFirestore.instance.collection(CollectionName.drivers);
      final queryLower = searchQuery.trim().toLowerCase();

      Query<Map<String, dynamic>> query;

      if (queryLower.isNotEmpty) {
        if (searchType == "email") {
          query = collection.where("searchEmailKeywords", arrayContains: queryLower).orderBy('createdAt', descending: true);
        } else if (searchType == "slug") {
          query = collection.where("searchNameKeywords", arrayContains: queryLower).orderBy('createdAt', descending: true);
        } else if (searchType == "phoneNumber") {
          query = collection
              .where("phoneNumber", isGreaterThanOrEqualTo: queryLower)
              .where("phoneNumber", isLessThanOrEqualTo: "$queryLower\uf8ff")
              .orderBy('createdAt', descending: true);
        } else {
          query = collection.orderBy('createdAt', descending: true);
        }
      } else {
        query = collection.orderBy('createdAt', descending: true);
      }

      // Pagination
      if (pageNumber > 1) {
        final previousDocs = await query.limit(pageSize * (pageNumber - 1)).get();
        if (previousDocs.docs.isNotEmpty) {
          lastDocument = previousDocs.docs.last;
        }
      }

      final finalQuery = lastDocument != null ? query.startAfterDocument(lastDocument) : query;

      final result = await finalQuery.limit(pageSize).get();

      driverList = result.docs.map((doc) => DriverUserModel.fromJson(doc.data())).toList();
    } catch (error) {
      log("get Users  error: $error");
    }

    return driverList;
  }

  static Future<List<DriverUserModel>> getUnverifiedDriver(
    int pageNumber,
    int pageSize,
    String searchQuery,
    String searchType,
  ) async {
    List<DriverUserModel> userList = [];
    DocumentSnapshot? lastDocument;

    try {
      Query baseQuery = fireStore.collection(CollectionName.drivers).where("isVerified", isEqualTo: false).orderBy('createdAt', descending: true);

      // 🔍 Search condition
      if (searchQuery.isNotEmpty) {
        baseQuery = baseQuery.where(
          searchType,
          isGreaterThanOrEqualTo: searchQuery,
          isLessThan: "$searchQuery\uf8ff",
        );
      }

      // 📄 Pagination: get last document of previous pages
      if (pageNumber > 1) {
        final previousDocs = await baseQuery.limit(pageSize * (pageNumber - 1)).get();

        if (previousDocs.docs.isNotEmpty) {
          lastDocument = previousDocs.docs.last;
        }
      }

      // ▶️ Apply startAfter if needed
      Query finalQuery = lastDocument != null ? baseQuery.startAfterDocument(lastDocument) : baseQuery;

      // 📥 Fetch page
      final snapshot = await finalQuery.limit(pageSize).get();

      // ✅ Filter verifyDocument (NOT empty)
      for (var element in snapshot.docs) {
        final driverModel = DriverUserModel.fromJson(element.data() as Map<String, dynamic>);

        if (driverModel.verifyDocument != null && driverModel.verifyDocument!.isNotEmpty) {
          userList.add(driverModel);
        }
      }
    } catch (error) {
      log(error.toString());
    }

    return userList;
  }

  static Future<List<DriverUserModel>> getVerifiedDriver(
    int pageNumber,
    int pageSize,
    String searchQuery,
    String searchType,
  ) async {
    List<DriverUserModel> userList = [];
    DocumentSnapshot? lastDocument;

    try {
      Query baseQuery = fireStore.collection(CollectionName.drivers).where("isVerified", isEqualTo: true).orderBy('createdAt', descending: true);

      // 🔍 Search condition
      if (searchQuery.isNotEmpty) {
        baseQuery = baseQuery.where(
          searchType,
          isGreaterThanOrEqualTo: searchQuery,
          isLessThan: "$searchQuery\uf8ff",
        );
      }

      // 📄 Pagination: get last document of previous pages
      if (pageNumber > 1) {
        final previousDocs = await baseQuery.limit(pageSize * (pageNumber - 1)).get();

        if (previousDocs.docs.isNotEmpty) {
          lastDocument = previousDocs.docs.last;
        }
      }

      // ▶️ Apply startAfter if needed
      Query finalQuery = lastDocument != null ? baseQuery.startAfterDocument(lastDocument) : baseQuery;

      // 📥 Fetch page
      final snapshot = await finalQuery.limit(pageSize).get();

      // ✅ Filter verifyDocument (NOT empty)
      for (var element in snapshot.docs) {
        final driverModel = DriverUserModel.fromJson(element.data() as Map<String, dynamic>);

        userList.add(driverModel);
      }
    } catch (error) {
      log(error.toString());
    }

    return userList;
  }

  static Future<List<DriverUserModel>> getAllDriver() async {
    List<DriverUserModel> driverUserModelList = [];
    try {
      final snapshot = await fireStore.collection(CollectionName.drivers).orderBy('createdAt', descending: true).get();
      for (var doc in snapshot.docs) {
        driverUserModelList.add(DriverUserModel.fromJson(doc.data()));
      }
    } catch (error) {
      log(error.toString());
    }
    return driverUserModelList;
  }

  static Future<bool> updateDriver(DriverUserModel driverUserModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.drivers).doc(driverUserModel.id).update(driverUserModel.toJson());
      return true;
    } catch (error) {
      return false;
    }
  }

  static Future<UserModel?> getUserByUserID(String id) async {
    UserModel? userModel;
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.users).doc(id).get();
      if (doc.exists) {
        userModel = UserModel.fromJson(doc.data()!);
      } else {
        userModel = UserModel(fullName: "Unknown User");
      }
    } catch (error) {
      return null;
    }
    return userModel;
  }

  static Future<VehicleTypeModel?> getVehicleByVehicleID(String id) async {
    VehicleTypeModel? userModel;
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.vehicleType).doc(id).get();
      if (doc.exists) {
        userModel = VehicleTypeModel.fromJson(doc.data()!);
      }
    } catch (error) {
      return null;
    }
    return userModel;
  }

  static Future<DocumentsModel?> getDocumentByDocumentId(String id) async {
    DocumentsModel? documentModel;
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.documents).doc(id).get();
      if (doc.exists) {
        documentModel = DocumentsModel.fromJson(doc.data()!);
      }
    } catch (error) {
      return null;
    }
    return documentModel;
  }

  static Future<DriverUserModel?> getDriverByDriverID(String id) async {
    DriverUserModel? driverUserModel;
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.drivers).doc(id).get();
      if (doc.exists) {
        driverUserModel = DriverUserModel.fromJson(doc.data()!);
      } else {
        driverUserModel = DriverUserModel(fullName: "Unknown Driver", phoneNumber: "N/A", countryCode: "");
      }
    } catch (error) {
      return null;
    }
    return driverUserModel;
  }

  static Future<BrandModel?> getVehicleBrandByBrandId(String id) async {
    BrandModel? vehicleBrandModel;
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.vehicleBrand).doc(id).get();
      if (doc.exists) {
        vehicleBrandModel = BrandModel.fromJson(doc.data()!);
      }
    } catch (error) {
      log("Failed to update user: $error");
    }
    return vehicleBrandModel;
  }

  static Future<int> countVehicleBrand() async {
    final productList = FirebaseFirestore.instance.collection(CollectionName.vehicleBrand);
    final query = await productList.count().get();
    Constant.vehicleBrandLength = query.count ?? 0;
    return query.count ?? 0;
  }

  static Future<List<BrandModel>> getVehicleBrand(int pageNumber, int pageSize) async {
    List<BrandModel> vehicleBrandModelList = [];
    try {
      DocumentSnapshot? lastDocument;
      if (pageNumber > 1) {
        var documents = await fireStore.collection(CollectionName.vehicleBrand).orderBy("title").limit(pageSize * (pageNumber - 1)).get();
        if (documents.docs.isNotEmpty) {
          lastDocument = documents.docs.last;
        }
      }
      if (lastDocument != null) {
        await fireStore.collection(CollectionName.vehicleBrand).orderBy("title").startAfterDocument(lastDocument).limit(pageSize).get().then((value) {
          for (var element in value.docs) {
            BrandModel vehicleBrandModel = BrandModel.fromJson(element.data());
            vehicleBrandModelList.add(vehicleBrandModel);
          }
        }).catchError((error) {
          log(error.toString());
        });
      } else {
        await fireStore.collection(CollectionName.vehicleBrand).orderBy("title").limit(pageSize).get().then((value) {
          for (var element in value.docs) {
            BrandModel vehicleBrandModel = BrandModel.fromJson(element.data());
            vehicleBrandModelList.add(vehicleBrandModel);
          }
        }).catchError((error) {
          log(error.toString());
        });
      }
    } catch (error) {
      log(error.toString());
    }
    return vehicleBrandModelList;
  }

  static Future<List<BrandModel>> getVehicleBrandAllData() async {
    List<BrandModel> vehicleBrandModelList = [];
    await fireStore.collection(CollectionName.vehicleBrand).orderBy("title").get().then((value) {
      for (var element in value.docs) {
        BrandModel vehicleBrandModel = BrandModel.fromJson(element.data());
        vehicleBrandModelList.add(vehicleBrandModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return vehicleBrandModelList;
  }

  static Future<bool> addVehicleBrand(BrandModel vehicleBrandModel) {
    return fireStore.collection(CollectionName.vehicleBrand).doc(vehicleBrandModel.id).set(vehicleBrandModel.toJson()).then(
      (value) {
        ShowToastDialog.successToast("Vehicle Brand Saved...!");

        return true;
      },
    ).catchError((error) {
      ShowToastDialog.errorToast("Something went wrong");

      return false;
    });
  }

  static Future<int> countVehicleModel() async {
    final CollectionReference<Map<String, dynamic>> productList = FirebaseFirestore.instance.collection(CollectionName.vehicleModel);
    AggregateQuerySnapshot query = await productList.count().get();
    Constant.vehicleModelLength = query.count ?? 0;
    return query.count ?? 0;
  }

  static Future<List<ModelVehicleModel>> getVehicleModel(int pageNumber, int pageSize, String id) async {
    List<ModelVehicleModel> modelVehicleModelList = [];
    try {
      if (id == "") {
        DocumentSnapshot? lastDocument;
        if (pageNumber > 1) {
          var documents = await fireStore.collection(CollectionName.vehicleModel).orderBy("title").limit(pageSize * (pageNumber - 1)).get();
          if (documents.docs.isNotEmpty) {
            lastDocument = documents.docs.last;
          }
        }
        if (lastDocument != null) {
          await fireStore.collection(CollectionName.vehicleModel).orderBy("title").startAfterDocument(lastDocument).limit(pageSize).get().then((value) {
            for (var element in value.docs) {
              ModelVehicleModel modelVehicleModel = ModelVehicleModel.fromJson(element.data());
              modelVehicleModelList.add(modelVehicleModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        } else {
          await fireStore.collection(CollectionName.vehicleModel).orderBy("title").limit(pageSize).get().then((value) {
            for (var element in value.docs) {
              ModelVehicleModel modelVehicleModel = ModelVehicleModel.fromJson(element.data());
              modelVehicleModelList.add(modelVehicleModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        }
      } else {
        DocumentSnapshot? lastDocument;
        if (pageNumber > 1) {
          var documents = await fireStore.collection(CollectionName.vehicleModel).where("brandId", isEqualTo: id).orderBy("title").limit(pageSize * (pageNumber - 1)).get();
          if (documents.docs.isNotEmpty) {
            lastDocument = documents.docs.last;
          }
        }
        if (lastDocument != null) {
          await fireStore
              .collection(CollectionName.vehicleModel)
              .where("brandId", isEqualTo: id)
              .orderBy("title")
              .startAfterDocument(lastDocument)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              ModelVehicleModel modelVehicleModel = ModelVehicleModel.fromJson(element.data());
              modelVehicleModelList.add(modelVehicleModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        } else {
          await fireStore.collection(CollectionName.vehicleModel).where("brandId", isEqualTo: id).orderBy("title").limit(pageSize).get().then((value) {
            for (var element in value.docs) {
              ModelVehicleModel modelVehicleModel = ModelVehicleModel.fromJson(element.data());
              modelVehicleModelList.add(modelVehicleModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        }
      }
    } catch (error) {
      log(error.toString());
    }
    return modelVehicleModelList;
  }

  static Future<bool> addVehicleModel(ModelVehicleModel modelVehicleModel) async {
    try {
      await fireStore.collection(CollectionName.vehicleModel).doc(modelVehicleModel.id).set(modelVehicleModel.toJson());
      ShowToastDialog.successToast("Model Saved...!");
      return true;
    } catch (error) {
      ShowToastDialog.errorToast("Something went wrong");
      return false;
    }
  }

  static Future<bool> updateVehicleModel(ModelVehicleModel modelVehicleModel) async {
    try {
      await fireStore.collection(CollectionName.vehicleModel).doc(modelVehicleModel.id).update(modelVehicleModel.toJson());
      ShowToastDialog.successToast("Model Updated...!");
      return true;
    } catch (error) {
      ShowToastDialog.errorToast("Something went wrong");
      return false;
    }
  }

  static Future<AdminModel?> getAdminProfile(String uuid) async {
    AdminModel? adminModel;

    await fireStore.collection(CollectionName.admin).doc(uuid).get().then((value) {
      if (value.exists) {
        Constant.adminModel = AdminModel.fromJson(value.data()!);
        adminModel = AdminModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      adminModel = null;
    });
    return adminModel;
  }

  static Future<AdminModel?> getAdmin() async {
    AdminModel? adminModel;
    try {
      var value = await FirebaseFirestore.instance.collection(CollectionName.admin).doc(FireStoreUtils.getCurrentUid()).get();
      if (value.exists) {
        adminModel = AdminModel.fromJson(value.data()!);
        Constant.adminModel = adminModel;
      }
    } catch (e, stack) {
      developer.log("Failed to fetch admin data", error: e, stackTrace: stack);
    }
    return adminModel;
  }

  static Future<bool> setAdmin(AdminModel adminModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.admin).doc(getCurrentUid()).set(adminModel.toJson());
      return true;
    } catch (error) {
      return false;
    }
  }

  static Future<List<LanguageModel>> getLanguage() async {
    List<LanguageModel> languageModelList = [];
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance.collection(CollectionName.languages).get();
      for (var document in snap.docs) {
        Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
        if (data != null) {
          languageModelList.add(LanguageModel.fromJson(data));
        } else {
          log('getLanguage is null ');
        }
      }
    } catch (error) {
      log('Error fetching languages: $error');
    }
    return languageModelList;
  }

  static Future<bool> addLanguage(LanguageModel languageModel) async {
    try {
      await fireStore.collection(CollectionName.languages).doc(languageModel.id).set(languageModel.toJson());
      return true;
    } catch (error) {
      ShowToastDialog.errorToast("Something went wrong");
      return false;
    }
  }

  static Future<bool> updateLanguage(LanguageModel languageModel) async {
    try {
      await fireStore.collection(CollectionName.languages).doc(languageModel.id).update(languageModel.toJson());
      return true;
    } catch (error) {
      ShowToastDialog.errorToast("Something went wrong");
      return false;
    }
  }

  static Future<PaymentModel?> getPayment() async {
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.settings).doc("payment").get();
      if (doc.exists) {
        final payment = PaymentModel.fromJson(doc.data()!);
        return payment;
      }
      return null;
    } catch (error) {
      log("Failed to update user: $error");
      return null;
    }
  }

  static Future<bool> setPayment(PaymentModel paymentModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.settings).doc("payment").update(paymentModel.toJson());
      ShowToastDialog.successToast("Saved...!");
      return true;
    } catch (error) {
      ShowToastDialog.errorToast("Something went wrong");
      return false;
    }
  }

  static Future<ConstantModel?> getGeneralSetting() async {
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.settings).doc("constant").get();
      if (doc.exists) {
        final constant = ConstantModel.fromJson(doc.data()!);
        Constant.constantModel = constant;
        return constant;
      }
      return null;
    } catch (error) {
      log("Failed to get getGeneral Setting: $error");
      return null;
    }
  }

  static Future<String?> getPrivacyPolicy(String type) async {
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.settings).doc("privacy_policy").get();
      if (doc.exists) {
        final data = doc.data()!;
        log("Privacy Policy Data: $data");
        return data["privacy_policy_$type"];
      }
      return null;
    } catch (error) {
      log("Failed to get getGeneral Setting: $error");
      return null;
    }
  }

  static Future<String?> getLandingPage() async {
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.settings).doc("landing_page").get();
      if (doc.exists) {
        final data = doc.data()!;
        log("Landing Page : $data");
        return data["content"];
      }
      return null;
    } catch (error) {
      log("Failed to get Landing Page: $error");
      return null;
    }
  }

  static Future<String?> getTermsAndCondition(String type) async {
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.settings).doc("terms_and_Conditions").get();
      if (doc.exists) {
        final data = doc.data()!;
        return data["terms_and_Conditions_$type"];
      }
      return null;
    } catch (error) {
      log("Failed to get getGeneral Setting: $error");
      return null;
    }
  }

  static Future<GlobalValueModel?> getGlobalValueSetting() async {
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.settings).doc("globalValue").get();
      if (doc.exists) {
        Constant.constantModel = ConstantModel.fromJson(doc.data()!);
        return GlobalValueModel.fromJson(doc.data()!);
      }
      return null;
    } catch (error) {
      log("Failed to get user: $error");
      return null;
    }
  }

  static Future<bool> setGlobalValueSetting(GlobalValueModel globalValueModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.settings).doc("globalValue").set(globalValueModel.toJson());
      return true;
    } catch (error) {
      log('error in set Global value $error');
      return false;
    }
  }

  static Future<bool> setGeneralSetting(ConstantModel constantModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.settings).doc("constant").set(constantModel.toJson(), SetOptions(merge: true));
      return true;
    } catch (error) {
      return false;
    }
  }

  static Future<bool> setPrivacyPolicy(String type, String data) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.settings).doc("privacy_policy").set({"privacy_policy_$type": data}, SetOptions(merge: true));
      return true;
    } catch (error) {
      return false;
    }
  }

  static Future<bool> setLandingPageData(String data) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.settings).doc("landing_page").set({"content": data}, SetOptions(merge: true));
      return true;
    } catch (error) {
      return false;
    }
  }

  static Future<bool> setTermsAndCondition(String type, String data) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.settings).doc("terms_and_Conditions").set({"terms_and_Conditions_$type": data}, SetOptions(merge: true));
      return true;
    } catch (error) {
      return false;
    }
  }

  static Future<List<TaxModel>?> getTax() async {
    List<TaxModel> taxList = [];
    try {
      final snapshot = await fireStore.collection(CollectionName.countryTax).get();
      for (var doc in snapshot.docs) {
        taxList.add(TaxModel.fromJson(doc.data()));
      }
    } catch (error) {
      log(error.toString());
    }
    return taxList;
  }

  static Future<bool> addTaxes(TaxModel taxModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.countryTax).doc(taxModel.id).set(taxModel.toJson());
      ShowToastDialog.successToast("Country Tax Saved...!");
      return true;
    } catch (error) {
      ShowToastDialog.errorToast("Something went wrong");
      return false;
    }
  }

  static Future<bool> addCancelingReason(List<String> reasonList) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.settings).doc("canceling_reason").set(<String, List<String>>{"reasons": reasonList});
      ShowToastDialog.successToast("Canceling Reason Saved...!");
      return true;
    } catch (error) {
      log('Error adding canceling reason: $error');
      ShowToastDialog.errorToast("Something went wrong");
      return false;
    }
  }

  static Future<List<String>> getCancelingReason() async {
    final List<String> reasonList = [];
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.settings).doc("canceling_reason").get();
      if (doc.exists) {
        final List<dynamic> data = doc.data()?["reasons"] ?? [];
        reasonList.addAll(data.map((e) => e.toString()));
      }
    } catch (error) {
      throw 'Error fetching canceling reasons: $error';
    }
    return reasonList;
  }

  static Future<bool> updateTax(TaxModel taxModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.countryTax).doc(taxModel.id).update(taxModel.toJson());
      ShowToastDialog.successToast("Country Tax Updated...!");
      return true;
    } catch (error) {
      ShowToastDialog.errorToast("Something went wrong");
      return false;
    }
  }

  static Future<bool> addCurrency(CurrencyModel currencyModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.currencies).doc(currencyModel.id).set(currencyModel.toJson());
      return true;
    } catch (error) {
      return false;
    }
  }

  static Future<bool> updateCurrency(CurrencyModel currencyModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.currencies).doc(currencyModel.id).update(currencyModel.toJson());
      return true;
    } catch (error) {
      return false;
    }
  }

  static Future<List<CurrencyModel>> getCurrencyList() async {
    try {
      final snap = await FirebaseFirestore.instance.collection(CollectionName.currencies).get();
      return snap.docs.map((doc) => CurrencyModel.fromJson(doc.data())).toList();
    } catch (error) {
      log('Error fetching currencies: $error');
      return [];
    }
  }

  static Future<bool> setContactusSetting(ContactUsModel contactUsModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.settings).doc("contact_us").set(contactUsModel.toJson());
      return true;
    } catch (error) {
      log('Error setting contact us: $error');
      return false;
    }
  }

  static Future<ContactUsModel?> getContactusSetting() async {
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.settings).doc("contact_us").get();
      if (doc.exists && doc.data() != null) {
        return ContactUsModel.fromJson(doc.data()!);
      }
      return null;
    } catch (error) {
      log("Failed to get contact us: $error");
      return null;
    }
  }

  static Future<AdminCommission?> getAdminCommission() async {
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.settings).doc("admin_commission").get();
      if (doc.exists && doc.data() != null) {
        return AdminCommission.fromJson(doc.data()!);
      }
      return null;
    } catch (error) {
      log("Failed to get admin commission: $error");
      return null;
    }
  }

  static Future<SMTPSettingModel?> getSMTPSettings() async {
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.settings).doc("smtp_settings").get();
      if (doc.exists && doc.data() != null) {
        return SMTPSettingModel.fromJson(doc.data()!);
      }
      return null;
    } catch (error) {
      log("Failed to get SMTP Settings: $error");
      return null;
    }
  }

  static Future<CancellationChargeModel?> getRideCancellationCharge() async {
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.settings).doc("ride_cancellation_charge").get();
      if (doc.exists && doc.data() != null) {
        return CancellationChargeModel.fromJson(doc.data()!);
      }
      return null;
    } catch (error) {
      log("Failed to get admin commission: $error");
      return null;
    }
  }

  static Future<bool> setRideCancellationCharge(CancellationChargeModel cancellationChargeModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.settings).doc("ride_cancellation_charge").set(cancellationChargeModel.toJson());
      return true;
    } catch (error) {
      log('Error setting admin commission: $error');
      return false;
    }
  }

  static Future<bool> setAdminCommission(AdminCommission adminCommissionModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.settings).doc("admin_commission").set(adminCommissionModel.toJson());
      return true;
    } catch (error) {
      log('Error setting admin commission: $error');
      return false;
    }
  }

  static Future<bool> setSMTPSettings(SMTPSettingModel smtpSettingModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.settings).doc("smtp_settings").set(smtpSettingModel.toJson());
      return true;
    } catch (error) {
      log('Error setting SMTP Setting: $error');
      return false;
    }
  }

  static Future<bool> addBanner(BannerModel bannerModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.banner).doc(bannerModel.id).set(bannerModel.toJson());
      return true;
    } catch (error) {
      log('Error adding banner: $error');
      return false;
    }
  }

  static Future<bool> addZones(ZoneModel zoneModel) {
    return FirebaseFirestore.instance.collection(CollectionName.zones).doc(zoneModel.id).set(zoneModel.toJson()).then(
      (value) {
        return true;
      },
    ).catchError((error) {
      return false;
    });
  }

  static Future<bool> addOnBoarding(OnboardingModel onBoardingModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.onBoarding).doc(onBoardingModel.id).set(onBoardingModel.toJson());
      return true;
    } catch (error) {
      log('Error adding banner: $error');
      return false;
    }
  }

  static Future<bool> updateBanner(BannerModel bannerModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.banner).doc(bannerModel.id).update(bannerModel.toJson());
      return true;
    } catch (error) {
      log('Error updating banner: $error');
      return false;
    }
  }

  static Future<bool> updateOnBoarding(OnboardingModel onBoardingModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.onBoarding).doc(onBoardingModel.id).update(onBoardingModel.toJson());
      return true;
    } catch (error) {
      log('Error updating onBoardings: $error');
      return false;
    }
  }

  static Future<List<BannerModel>> getBanner() async {
    try {
      final snap = await FirebaseFirestore.instance.collection(CollectionName.banner).get();
      return snap.docs.map((doc) => BannerModel.fromJson(doc.data())).toList();
    } catch (error) {
      log('Error fetching banners: $error');
      return [];
    }
  }

  static Future<List<ZoneModel>?> getZones() async {
    List<ZoneModel> zoneList = [];
    try {
      final snapshot = await fireStore.collection(CollectionName.zones).get();
      for (var doc in snapshot.docs) {
        zoneList.add(ZoneModel.fromJson(doc.data()));
      }
    } catch (error) {
      log(error.toString());
    }
    return zoneList;
  }

  static Future<List<ZoneModel>?> getActiveZones() async {
    List<ZoneModel> zoneList = [];
    try {
      final snapshot = await fireStore.collection(CollectionName.zones).where("status", isEqualTo: true).orderBy("createdAt", descending: true).get();
      for (var doc in snapshot.docs) {
        zoneList.add(ZoneModel.fromJson(doc.data()));
      }
    } catch (error) {
      log(error.toString());
    }
    return zoneList;
  }

  static Future<List<OnboardingModel>> getOnBoarding() async {
    try {
      final snap = await FirebaseFirestore.instance.collection(CollectionName.onBoarding).get();
      return snap.docs.map((doc) => OnboardingModel.fromJson(doc.data())).toList();
    } catch (error) {
      log('Error fetching onBoardings: $error');
      return [];
    }
  }

  static Future<bool> addRentalPackage(RentalPackageModel rentalPackageModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.rentalPackage).doc(rentalPackageModel.id).set(rentalPackageModel.toJson());
      return true;
    } catch (error) {
      log('Error adding Rentals: $error');
      return false;
    }
  }

  static Future<List<RentalPackageModel>> getRentalPackage() async {
    try {
      final snap = await FirebaseFirestore.instance.collection(CollectionName.rentalPackage).get();
      return snap.docs.map((doc) => RentalPackageModel.fromJson(doc.data())).toList();
    } catch (error) {
      log('Error fetching Rentals: $error');
      return [];
    }
  }

  static Future<bool> updateRentalPackage(RentalPackageModel rentalPackageModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.rentalPackage).doc(rentalPackageModel.id).update(rentalPackageModel.toJson());
      return true;
    } catch (error) {
      log('Error updating subscription: $error');
      return false;
    }
  }

  static Future<String> uploadPic(PickedFile image, String fileName, String filePath, String mimeType) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(fileName).child(filePath);
      final uploadTask = ref.putData(
        await image.readAsBytes(),
        SettableMetadata(
          contentType: mimeType,
          customMetadata: {'picked-file-path': image.path},
        ),
      );
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (error) {
      log('Error uploading picture: $error');
      rethrow;
    }
  }

  static Future<List<DocumentsModel>> getDocument() async {
    try {
      final snap = await fireStore.collection(CollectionName.documents).get();
      return snap.docs.map((doc) => DocumentsModel.fromJson(doc.data())).toList();
    } catch (error) {
      log('Error fetching documents: $error');
      return [];
    }
  }

  static Future<bool> addDocument(DocumentsModel documentModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.documents).doc(documentModel.id).set(documentModel.toJson());
      ShowToastDialog.successToast("Save Document...!");
      return true;
    } catch (error) {
      log('Error adding document: $error');
      return false;
    }
  }

  static Future<bool> addVehicleType(VehicleTypeModel vehicleTypeModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.vehicleType).doc(vehicleTypeModel.id).set(vehicleTypeModel.toJson());
      ShowToastDialog.successToast("Save VehicleType...!");
      return true;
    } catch (error) {
      log('Error adding vehicle type: $error');
      return false;
    }
  }

  static Future<List<BookingModel>> getBookingByDriverId(String? status, String? driverId) async {
    try {
      QuerySnapshot querySnapshot;
      final collection = fireStore.collection(CollectionName.bookings);
      if (status == 'All') {
        querySnapshot = await collection.where('driverId', isEqualTo: driverId).orderBy('createAt', descending: true).get();
      } else {
        querySnapshot = await collection.where('driverId', isEqualTo: driverId).where('bookingStatus', isEqualTo: status).orderBy('createAt', descending: true).get();
      }
      return querySnapshot.docs.map((doc) => BookingModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (error) {
      log('Error in get booking history: $error');
      return [];
    }
  }

  static Future<List<VehicleTypeModel>> getVehicleType() async {
    try {
      final snap = await fireStore.collection(CollectionName.vehicleType).get();
      return snap.docs.map((doc) => VehicleTypeModel.fromJson(doc.data())).toList();
    } catch (error) {
      log('Error in getVehicleType: $error');
      return [];
    }
  }

  static Future<List<WithdrawModel>> getPayoutRequest({
    String status = "All",
    required String driverId,
    DateTimeRange? dateTimeRange,
  }) async {
    try {
      Query query = FirebaseFirestore.instance.collection(CollectionName.withDrawHistory);

      if (dateTimeRange != null) {
        query = query.where('createdDate', isGreaterThanOrEqualTo: dateTimeRange.start).where('createdDate', isLessThanOrEqualTo: dateTimeRange.end);
      }
      if (status != "All") {
        query = query.where('paymentStatus', isEqualTo: status);
      }
      if (driverId != "All" && driverId.trim().isNotEmpty) {
        query = query.where('driverId', isEqualTo: driverId);
      }

      final snap = await query.get();
      return snap.docs.map((doc) => WithdrawModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (error) {
      log("Error in getPayoutRequest: $error");
      return [];
    }
  }

  static Future<int> countBooking() async {
    try {
      final query = await FirebaseFirestore.instance.collection(CollectionName.bookings).count().get();
      Constant.bookingLength = query.count ?? 0;
      return query.count ?? 0;
    } catch (error) {
      log('Error in countBooking: $error');
      return 0;
    }
  }

  static Future<int> countRentalRide() async {
    try {
      final query = await FirebaseFirestore.instance.collection(CollectionName.rentalRide).count().get();
      Constant.rentalRideLength = query.count ?? 0;
      return query.count ?? 0;
    } catch (error) {
      log('Error in count Rental Ride: $error');
      return 0;
    }
  }

  static Future<int> countSubscriptionHistory() async {
    try {
      final query = await FirebaseFirestore.instance.collection(CollectionName.subscriptionHistory).count().get();
      Constant.subscriptionLength = query.count ?? 0;
      return query.count ?? 0;
    } catch (error) {
      log('Error in countSubscriptionHistory: $error');
      return 0;
    }
  }

  static Future<int> countParcelBooking() async {
    try {
      final query = await FirebaseFirestore.instance.collection(CollectionName.parcelRide).count().get();
      Constant.parcelBookingLength = query.count ?? 0;
      return query.count ?? 0;
    } catch (error) {
      log('Error in countParcelBooking: $error');
      return 0;
    }
  }

  static Future<int> countInterCityBooking() async {
    try {
      final query = await FirebaseFirestore.instance.collection(CollectionName.interCityRide).count().get();
      Constant.interCityBookingLength = query.count ?? 0;
      log('The number of InterCity Bookings: ${query.count}');
      return query.count ?? 0;
    } catch (error) {
      log('Error in countInterCityBooking: $error');
      return 0;
    }
  }

  static Future<int> countSubscriptionPlan(String? driverId, DateTimeRange? dateTimeRange) async {
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection(CollectionName.subscriptionHistory);

      if (dateTimeRange != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: dateTimeRange.start, isLessThan: dateTimeRange.end);
      }
      if (driverId != null && driverId != '' && driverId != 'All') {
        query = query.where('driverId', isEqualTo: driverId);
      }

      final result = await query.count().get();
      Constant.subscriptionLength = result.count ?? 0;
      log('The number of Subscription Plans: ${result.count}');
      return result.count ?? 0;
    } catch (error) {
      log('Error in countSubscriptionPlan: $error');
      return 0;
    }
  }

  static Future<int> countStatusWiseBooking(String? driverId, String? status, DateTimeRange? dateTimeRange) async {
    final CollectionReference<Map<String, dynamic>> ordersCollection = FirebaseFirestore.instance.collection(CollectionName.bookings);

    Query<Map<String, dynamic>> bookingList = ordersCollection;

    bookingList = bookingList.where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start).where('createAt', isLessThan: dateTimeRange.end);

    if (status != null && status != 'All') {
      bookingList = bookingList.where('bookingStatus', isEqualTo: status);
    }

    if (driverId != null && driverId != '' && driverId != 'All') {
      bookingList = bookingList.where('driverId', isEqualTo: driverId);
    }

    AggregateQuerySnapshot query = await bookingList.count().get();
    Constant.bookingLength = query.count ?? 0;
    log('====================> get of count ${query.count}');
    return query.count ?? 0;
  }

  static Future<int> countStatusWiseInterCity(String? driverId, String? status, DateTimeRange? dateTimeRange) async {
    final CollectionReference<Map<String, dynamic>> ordersCollection = FirebaseFirestore.instance.collection(CollectionName.interCityRide);

    Query<Map<String, dynamic>> bookingList = ordersCollection;

    bookingList = bookingList.where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start).where('createAt', isLessThan: dateTimeRange.end);

    if (status != null && status != 'All') {
      bookingList = bookingList.where('bookingStatus', isEqualTo: status);
    }

    if (driverId != null && driverId != '' && driverId != 'All') {
      bookingList = bookingList.where('driverId', isEqualTo: driverId);
    }

    AggregateQuerySnapshot query = await bookingList.count().get();
    Constant.interCityBookingLength = query.count ?? 0;
    log('====================> get of count interCityBookingLength ${query.count}');
    return query.count ?? 0;
  }

  static Future<int> countStatusParcel(String? driverId, String? status, DateTimeRange? dateTimeRange) async {
    final CollectionReference<Map<String, dynamic>> ordersCollection = FirebaseFirestore.instance.collection(CollectionName.parcelRide);

    Query<Map<String, dynamic>> bookingList = ordersCollection;

    bookingList = bookingList.where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start).where('createAt', isLessThan: dateTimeRange.end);

    if (status != null && status != 'All') {
      bookingList = bookingList.where('bookingStatus', isEqualTo: status);
    }

    if (driverId != null && driverId != '' && driverId != 'All') {
      bookingList = bookingList.where('driverId', isEqualTo: driverId);
    }

    AggregateQuerySnapshot query = await bookingList.count().get();
    Constant.parcelBookingLength = query.count ?? 0;
    log('====================> get of count interCityBookingLength ${query.count}');
    return query.count ?? 0;
  }

  static Future<int> countStatusWiseRentalRide(String? driverId, String? status, DateTimeRange? dateTimeRange) async {
    final CollectionReference<Map<String, dynamic>> ordersCollection = FirebaseFirestore.instance.collection(CollectionName.rentalRide);

    Query<Map<String, dynamic>> bookingList = ordersCollection;

    bookingList = bookingList.where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start).where('createAt', isLessThan: dateTimeRange.end);

    if (status != null && status != 'All') {
      bookingList = bookingList.where('bookingStatus', isEqualTo: status);
    }

    if (driverId != null && driverId != '' && driverId != 'All') {
      bookingList = bookingList.where('driverId', isEqualTo: driverId);
    }

    AggregateQuerySnapshot query = await bookingList.count().get();
    Constant.rentalRideLength = query.count ?? 0;
    log('====================> get of count ${query.count}');
    return query.count ?? 0;
  }

  static Future<List<BookingModel>> getBooking(int pageNumber, int pageSize, String? status, DateTimeRange? dateTimeRange, String driverId) async {
    List<BookingModel> bookingList = [];
    try {
      if (status == 'All' && (driverId == '' || driverId == 'All')) {
        DocumentSnapshot? lastDocument;
        if (pageNumber > 1) {
          var documents = await fireStore
              .collection(CollectionName.bookings)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .limit(pageSize * (pageNumber - 1))
              .get();
          if (documents.docs.isNotEmpty) {
            lastDocument = documents.docs.last;
          }
        }
        if (lastDocument != null) {
          await fireStore
              .collection(CollectionName.bookings)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .startAfterDocument(lastDocument)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              BookingModel bookingModel = BookingModel.fromJson(element.data());
              bookingList.add(bookingModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        } else {
          await fireStore
              .collection(CollectionName.bookings)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              BookingModel bookingModel = BookingModel.fromJson(element.data());
              bookingList.add(bookingModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        }
      } else if (driverId != 'All' && driverId != '') {
        if (status == 'All') {
          DocumentSnapshot? lastDocument;
          if (pageNumber > 1) {
            var documents = await fireStore
                .collection(CollectionName.bookings)
                .where('driverId', isEqualTo: driverId)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .limit(pageSize * (pageNumber - 1))
                .get();
            if (documents.docs.isNotEmpty) {
              lastDocument = documents.docs.last;
            }
          }
          if (lastDocument != null) {
            await fireStore
                .collection(CollectionName.bookings)
                .where('driverId', isEqualTo: driverId)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .startAfterDocument(lastDocument)
                .limit(pageSize)
                .get()
                .then((value) {
              for (var element in value.docs) {
                BookingModel orderModel = BookingModel.fromJson(element.data());
                bookingList.add(orderModel);
              }
            }).catchError((error) {
              log(error.toString());
            });
          } else {
            await fireStore
                .collection(CollectionName.bookings)
                .where('driverId', isEqualTo: driverId)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .limit(pageSize)
                .get()
                .then((value) {
              for (var element in value.docs) {
                BookingModel orderModel = BookingModel.fromJson(element.data());
                bookingList.add(orderModel);
              }
            }).catchError((error) {
              log(error.toString());
            });
          }
        } else {
          DocumentSnapshot? lastDocument;
          if (pageNumber > 1) {
            var documents = await fireStore
                .collection(CollectionName.bookings)
                .where('driverId', isEqualTo: driverId)
                .where('bookingStatus', isEqualTo: status)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .limit(pageSize * (pageNumber - 1))
                .get();
            if (documents.docs.isNotEmpty) {
              lastDocument = documents.docs.last;
            }
          }
          if (lastDocument != null) {
            await fireStore
                .collection(CollectionName.bookings)
                .where('driverId', isEqualTo: driverId)
                .where('bookingStatus', isEqualTo: status)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .startAfterDocument(lastDocument)
                .limit(pageSize)
                .get()
                .then((value) {
              for (var element in value.docs) {
                BookingModel orderModel = BookingModel.fromJson(element.data());
                bookingList.add(orderModel);
              }
            }).catchError((error) {
              log(error.toString());
            });
          } else {
            await fireStore
                .collection(CollectionName.bookings)
                .where('driverId', isEqualTo: driverId)
                .where('bookingStatus', isEqualTo: status)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .limit(pageSize)
                .get()
                .then((value) {
              for (var element in value.docs) {
                BookingModel orderModel = BookingModel.fromJson(element.data());
                bookingList.add(orderModel);
              }
            }).catchError((error) {
              log(error.toString());
            });
          }
        }
      } else {
        DocumentSnapshot? lastDocument;
        if (pageNumber > 1) {
          var documents = await fireStore
              .collection(CollectionName.bookings)
              .where('bookingStatus', isEqualTo: status)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .limit(pageSize * (pageNumber - 1))
              .get();
          if (documents.docs.isNotEmpty) {
            lastDocument = documents.docs.last;
          }
        }
        if (lastDocument != null) {
          await fireStore
              .collection(CollectionName.bookings)
              .where('bookingStatus', isEqualTo: status)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .startAfterDocument(lastDocument)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              BookingModel bookingModel = BookingModel.fromJson(element.data());
              bookingList.add(bookingModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        } else {
          await fireStore
              .collection(CollectionName.bookings)
              .where('bookingStatus', isEqualTo: status)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              BookingModel bookingModel = BookingModel.fromJson(element.data());
              bookingList.add(bookingModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        }
      }
    } catch (error) {
      log(error.toString());
    }
    return bookingList;
  }

  static Future<List<IntercityModel>> getInterCityBooking(String driverId, int pageNumber, int pageSize, String? status, DateTimeRange? dateTimeRange) async {
    List<IntercityModel> interCityBookingList = [];
    try {
      if (status == 'All' && (driverId == '' || driverId == 'All')) {
        DocumentSnapshot? lastDocument;
        if (pageNumber > 1) {
          var documents = await fireStore
              .collection(CollectionName.interCityRide)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .limit(pageSize * (pageNumber - 1))
              .get();
          if (documents.docs.isNotEmpty) {
            lastDocument = documents.docs.last;
          }
        }
        if (lastDocument != null) {
          await fireStore
              .collection(CollectionName.interCityRide)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .startAfterDocument(lastDocument)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              IntercityModel bookingModel = IntercityModel.fromJson(element.data());
              interCityBookingList.add(bookingModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        } else {
          await fireStore
              .collection(CollectionName.interCityRide)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              IntercityModel bookingModel = IntercityModel.fromJson(element.data());
              interCityBookingList.add(bookingModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        }
      } else if (driverId != 'All' && driverId != '') {
        if (status == 'All') {
          DocumentSnapshot? lastDocument;
          if (pageNumber > 1) {
            var documents = await fireStore
                .collection(CollectionName.interCityRide)
                .where('driverId', isEqualTo: driverId)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .limit(pageSize * (pageNumber - 1))
                .get();
            if (documents.docs.isNotEmpty) {
              lastDocument = documents.docs.last;
            }
          }
          if (lastDocument != null) {
            await fireStore
                .collection(CollectionName.interCityRide)
                .where('driverId', isEqualTo: driverId)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .startAfterDocument(lastDocument)
                .limit(pageSize)
                .get()
                .then((value) {
              for (var element in value.docs) {
                IntercityModel orderModel = IntercityModel.fromJson(element.data());
                interCityBookingList.add(orderModel);
              }
            }).catchError((error) {
              log(error.toString());
            });
          } else {
            await fireStore
                .collection(CollectionName.interCityRide)
                .where('driverId', isEqualTo: driverId)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .limit(pageSize)
                .get()
                .then((value) {
              for (var element in value.docs) {
                IntercityModel orderModel = IntercityModel.fromJson(element.data());
                interCityBookingList.add(orderModel);
              }
            }).catchError((error) {
              log(error.toString());
            });
          }
        } else {
          DocumentSnapshot? lastDocument;
          if (pageNumber > 1) {
            var documents = await fireStore
                .collection(CollectionName.interCityRide)
                .where('driverId', isEqualTo: driverId)
                .where('bookingStatus', isEqualTo: status)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .limit(pageSize * (pageNumber - 1))
                .get();
            if (documents.docs.isNotEmpty) {
              lastDocument = documents.docs.last;
            }
          }
          if (lastDocument != null) {
            await fireStore
                .collection(CollectionName.interCityRide)
                .where('driverId', isEqualTo: driverId)
                .where('bookingStatus', isEqualTo: status)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .startAfterDocument(lastDocument)
                .limit(pageSize)
                .get()
                .then((value) {
              for (var element in value.docs) {
                IntercityModel orderModel = IntercityModel.fromJson(element.data());
                interCityBookingList.add(orderModel);
              }
            }).catchError((error) {
              log(error.toString());
            });
          } else {
            await fireStore
                .collection(CollectionName.interCityRide)
                .where('driverId', isEqualTo: driverId)
                .where('bookingStatus', isEqualTo: status)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .limit(pageSize)
                .get()
                .then((value) {
              for (var element in value.docs) {
                IntercityModel orderModel = IntercityModel.fromJson(element.data());
                interCityBookingList.add(orderModel);
              }
            }).catchError((error) {
              log(error.toString());
            });
          }
        }
      } else {
        DocumentSnapshot? lastDocument;
        if (pageNumber > 1) {
          var documents = await fireStore
              .collection(CollectionName.interCityRide)
              .where('bookingStatus', isEqualTo: status)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .limit(pageSize * (pageNumber - 1))
              .get();
          if (documents.docs.isNotEmpty) {
            lastDocument = documents.docs.last;
          }
        }
        if (lastDocument != null) {
          await fireStore
              .collection(CollectionName.interCityRide)
              .where('bookingStatus', isEqualTo: status)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .startAfterDocument(lastDocument)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              IntercityModel bookingModel = IntercityModel.fromJson(element.data());
              interCityBookingList.add(bookingModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        } else {
          await fireStore
              .collection(CollectionName.interCityRide)
              .where('bookingStatus', isEqualTo: status)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              IntercityModel bookingModel = IntercityModel.fromJson(element.data());
              interCityBookingList.add(bookingModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        }
      }
    } catch (error) {
      log(error.toString());
    }
    return interCityBookingList;
  }

  static Future<List<ParcelModel>> getParcelBooking(String driverId, int pageNumber, int pageSize, String? status, DateTimeRange? dateTimeRange) async {
    List<ParcelModel> parcelBookingList = [];
    try {
      if (status == 'All' && (driverId == '' || driverId == 'All')) {
        DocumentSnapshot? lastDocument;
        if (pageNumber > 1) {
          var documents = await fireStore
              .collection(CollectionName.parcelRide)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .limit(pageSize * (pageNumber - 1))
              .get();
          if (documents.docs.isNotEmpty) {
            lastDocument = documents.docs.last;
          }
        }
        if (lastDocument != null) {
          await fireStore
              .collection(CollectionName.parcelRide)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .startAfterDocument(lastDocument)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              ParcelModel bookingModel = ParcelModel.fromJson(element.data());
              parcelBookingList.add(bookingModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        } else {
          await fireStore
              .collection(CollectionName.parcelRide)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              ParcelModel bookingModel = ParcelModel.fromJson(element.data());
              parcelBookingList.add(bookingModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        }
      } else if (driverId != 'All' && driverId != '') {
        if (status == 'All') {
          DocumentSnapshot? lastDocument;
          if (pageNumber > 1) {
            var documents = await fireStore
                .collection(CollectionName.parcelRide)
                .where('driverId', isEqualTo: driverId)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .limit(pageSize * (pageNumber - 1))
                .get();
            if (documents.docs.isNotEmpty) {
              lastDocument = documents.docs.last;
            }
          }
          if (lastDocument != null) {
            await fireStore
                .collection(CollectionName.parcelRide)
                .where('driverId', isEqualTo: driverId)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .startAfterDocument(lastDocument)
                .limit(pageSize)
                .get()
                .then((value) {
              for (var element in value.docs) {
                ParcelModel parcelModel = ParcelModel.fromJson(element.data());
                parcelBookingList.add(parcelModel);
              }
            }).catchError((error) {
              log(error.toString());
            });
          } else {
            await fireStore
                .collection(CollectionName.parcelRide)
                .where('driverId', isEqualTo: driverId)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .limit(pageSize)
                .get()
                .then((value) {
              for (var element in value.docs) {
                ParcelModel parcelModel = ParcelModel.fromJson(element.data());
                parcelBookingList.add(parcelModel);
              }
            }).catchError((error) {
              log(error.toString());
            });
          }
        } else {
          DocumentSnapshot? lastDocument;
          if (pageNumber > 1) {
            var documents = await fireStore
                .collection(CollectionName.parcelRide)
                .where('driverId', isEqualTo: driverId)
                .where('bookingStatus', isEqualTo: status)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .limit(pageSize * (pageNumber - 1))
                .get();
            if (documents.docs.isNotEmpty) {
              lastDocument = documents.docs.last;
            }
          }
          if (lastDocument != null) {
            await fireStore
                .collection(CollectionName.parcelRide)
                .where('driverId', isEqualTo: driverId)
                .where('bookingStatus', isEqualTo: status)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .startAfterDocument(lastDocument)
                .limit(pageSize)
                .get()
                .then((value) {
              for (var element in value.docs) {
                ParcelModel parcelModel = ParcelModel.fromJson(element.data());
                parcelBookingList.add(parcelModel);
              }
            }).catchError((error) {
              log(error.toString());
            });
          } else {
            await fireStore
                .collection(CollectionName.parcelRide)
                .where('driverId', isEqualTo: driverId)
                .where('bookingStatus', isEqualTo: status)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .limit(pageSize)
                .get()
                .then((value) {
              for (var element in value.docs) {
                ParcelModel parcelModel = ParcelModel.fromJson(element.data());
                parcelBookingList.add(parcelModel);
              }
            }).catchError((error) {
              log(error.toString());
            });
          }
        }
      } else {
        DocumentSnapshot? lastDocument;
        if (pageNumber > 1) {
          var documents = await fireStore
              .collection(CollectionName.parcelRide)
              .where('bookingStatus', isEqualTo: status)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .limit(pageSize * (pageNumber - 1))
              .get();
          if (documents.docs.isNotEmpty) {
            lastDocument = documents.docs.last;
          }
        }
        if (lastDocument != null) {
          await fireStore
              .collection(CollectionName.parcelRide)
              .where('bookingStatus', isEqualTo: status)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .startAfterDocument(lastDocument)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              ParcelModel bookingModel = ParcelModel.fromJson(element.data());
              parcelBookingList.add(bookingModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        } else {
          await fireStore
              .collection(CollectionName.parcelRide)
              .where('bookingStatus', isEqualTo: status)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              ParcelModel bookingModel = ParcelModel.fromJson(element.data());
              parcelBookingList.add(bookingModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        }
      }
    } catch (error) {
      log(error.toString());
    }
    return parcelBookingList;
  }

  static Future<List<RentalBookingModel>> getRentalRide(int pageNumber, int pageSize, String? status, DateTimeRange? dateTimeRange, String driverId) async {
    List<RentalBookingModel> bookingList = [];
    try {
      if (status == 'All' && (driverId == '' || driverId == 'All')) {
        DocumentSnapshot? lastDocument;
        if (pageNumber > 1) {
          var documents = await fireStore
              .collection(CollectionName.rentalRide)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .limit(pageSize * (pageNumber - 1))
              .get();
          if (documents.docs.isNotEmpty) {
            lastDocument = documents.docs.last;
          }
        }
        if (lastDocument != null) {
          await fireStore
              .collection(CollectionName.rentalRide)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .startAfterDocument(lastDocument)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              RentalBookingModel bookingModel = RentalBookingModel.fromJson(element.data());
              bookingList.add(bookingModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        } else {
          await fireStore
              .collection(CollectionName.rentalRide)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              RentalBookingModel bookingModel = RentalBookingModel.fromJson(element.data());
              bookingList.add(bookingModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        }
      } else if (driverId != 'All' && driverId != '') {
        if (status == 'All') {
          DocumentSnapshot? lastDocument;
          if (pageNumber > 1) {
            var documents = await fireStore
                .collection(CollectionName.rentalRide)
                .where('driverId', isEqualTo: driverId)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .limit(pageSize * (pageNumber - 1))
                .get();
            if (documents.docs.isNotEmpty) {
              lastDocument = documents.docs.last;
            }
          }
          if (lastDocument != null) {
            await fireStore
                .collection(CollectionName.rentalRide)
                .where('driverId', isEqualTo: driverId)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .startAfterDocument(lastDocument)
                .limit(pageSize)
                .get()
                .then((value) {
              for (var element in value.docs) {
                RentalBookingModel orderModel = RentalBookingModel.fromJson(element.data());
                bookingList.add(orderModel);
              }
            }).catchError((error) {
              log(error.toString());
            });
          } else {
            await fireStore
                .collection(CollectionName.rentalRide)
                .where('driverId', isEqualTo: driverId)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .limit(pageSize)
                .get()
                .then((value) {
              for (var element in value.docs) {
                RentalBookingModel orderModel = RentalBookingModel.fromJson(element.data());
                bookingList.add(orderModel);
              }
            }).catchError((error) {
              log(error.toString());
            });
          }
        } else {
          DocumentSnapshot? lastDocument;
          if (pageNumber > 1) {
            var documents = await fireStore
                .collection(CollectionName.rentalRide)
                .where('driverId', isEqualTo: driverId)
                .where('bookingStatus', isEqualTo: status)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .limit(pageSize * (pageNumber - 1))
                .get();
            if (documents.docs.isNotEmpty) {
              lastDocument = documents.docs.last;
            }
          }
          if (lastDocument != null) {
            await fireStore
                .collection(CollectionName.rentalRide)
                .where('driverId', isEqualTo: driverId)
                .where('bookingStatus', isEqualTo: status)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .startAfterDocument(lastDocument)
                .limit(pageSize)
                .get()
                .then((value) {
              for (var element in value.docs) {
                RentalBookingModel orderModel = RentalBookingModel.fromJson(element.data());
                bookingList.add(orderModel);
              }
            }).catchError((error) {
              log(error.toString());
            });
          } else {
            await fireStore
                .collection(CollectionName.rentalRide)
                .where('driverId', isEqualTo: driverId)
                .where('bookingStatus', isEqualTo: status)
                .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
                .orderBy('createAt', descending: true)
                .limit(pageSize)
                .get()
                .then((value) {
              for (var element in value.docs) {
                RentalBookingModel orderModel = RentalBookingModel.fromJson(element.data());
                bookingList.add(orderModel);
              }
            }).catchError((error) {
              log(error.toString());
            });
          }
        }
      } else {
        DocumentSnapshot? lastDocument;
        if (pageNumber > 1) {
          var documents = await fireStore
              .collection(CollectionName.rentalRide)
              .where('bookingStatus', isEqualTo: status)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .limit(pageSize * (pageNumber - 1))
              .get();
          if (documents.docs.isNotEmpty) {
            lastDocument = documents.docs.last;
          }
        }
        if (lastDocument != null) {
          await fireStore
              .collection(CollectionName.rentalRide)
              .where('bookingStatus', isEqualTo: status)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .startAfterDocument(lastDocument)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              RentalBookingModel bookingModel = RentalBookingModel.fromJson(element.data());
              bookingList.add(bookingModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        } else {
          await fireStore
              .collection(CollectionName.rentalRide)
              .where('bookingStatus', isEqualTo: status)
              .where('createAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createAt', descending: true)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              RentalBookingModel bookingModel = RentalBookingModel.fromJson(element.data());
              bookingList.add(bookingModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        }
      }
    } catch (error) {
      log(error.toString());
    }
    return bookingList;
  }

  static Future<List<SubscriptionHistoryModel>> getSubscriptionHistory(String driverId, int pageNumber, int pageSize, DateTimeRange? dateTimeRange) async {
    List<SubscriptionHistoryModel> subscriptionHistoryList = [];
    try {
      if (driverId == '' || driverId == 'All') {
        DocumentSnapshot? lastDocument;
        if (pageNumber > 1) {
          var documents = await fireStore
              .collection(CollectionName.subscriptionHistory)
              .where('createdAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createdAt', descending: true)
              .limit(pageSize * (pageNumber - 1))
              .get();
          if (documents.docs.isNotEmpty) {
            lastDocument = documents.docs.last;
          }
        }
        if (lastDocument != null) {
          await fireStore
              .collection(CollectionName.subscriptionHistory)
              .where('createdAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createdAt', descending: true)
              .startAfterDocument(lastDocument)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              SubscriptionHistoryModel subscriptionModel = SubscriptionHistoryModel.fromJson(element.data());
              subscriptionHistoryList.add(subscriptionModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        } else {
          await fireStore
              .collection(CollectionName.subscriptionHistory)
              .where('createdAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createdAt', descending: true)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              SubscriptionHistoryModel subscriptionModel = SubscriptionHistoryModel.fromJson(element.data());
              subscriptionHistoryList.add(subscriptionModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        }
      } else if (driverId != 'All' && driverId != '') {
        DocumentSnapshot? lastDocument;
        if (pageNumber > 1) {
          var documents = await fireStore
              .collection(CollectionName.subscriptionHistory)
              .where('driverId', isEqualTo: driverId)
              .where('createdAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createdAt', descending: true)
              .limit(pageSize * (pageNumber - 1))
              .get();
          if (documents.docs.isNotEmpty) {
            lastDocument = documents.docs.last;
          }
        }
        if (lastDocument != null) {
          await fireStore
              .collection(CollectionName.subscriptionHistory)
              .where('driverId', isEqualTo: driverId)
              .where('createdAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createdAt', descending: true)
              .startAfterDocument(lastDocument)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              SubscriptionHistoryModel subscriptionModel = SubscriptionHistoryModel.fromJson(element.data());
              subscriptionHistoryList.add(subscriptionModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        } else {
          await fireStore
              .collection(CollectionName.subscriptionHistory)
              .where('driverId', isEqualTo: driverId)
              .where('createdAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createdAt', descending: true)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              SubscriptionHistoryModel subscriptionModel = SubscriptionHistoryModel.fromJson(element.data());
              subscriptionHistoryList.add(subscriptionModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        }
      } else {
        DocumentSnapshot? lastDocument;
        if (pageNumber > 1) {
          var documents = await fireStore
              .collection(CollectionName.subscriptionHistory)
              .where('createdAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createdAt', descending: true)
              .limit(pageSize * (pageNumber - 1))
              .get();
          if (documents.docs.isNotEmpty) {
            lastDocument = documents.docs.last;
          }
        }
        if (lastDocument != null) {
          await fireStore
              .collection(CollectionName.subscriptionHistory)
              .where('createdAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createdAt', descending: true)
              .startAfterDocument(lastDocument)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              SubscriptionHistoryModel subscriptionModel = SubscriptionHistoryModel.fromJson(element.data());
              subscriptionHistoryList.add(subscriptionModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        } else {
          await fireStore
              .collection(CollectionName.subscriptionHistory)
              .where('createdAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
              .orderBy('createdAt', descending: true)
              .limit(pageSize)
              .get()
              .then((value) {
            for (var element in value.docs) {
              SubscriptionHistoryModel subscriptionModel = SubscriptionHistoryModel.fromJson(element.data());
              subscriptionHistoryList.add(subscriptionModel);
            }
          }).catchError((error) {
            log(error.toString());
          });
        }
      }
    } catch (error) {
      log(error.toString());
    }
    return subscriptionHistoryList;
  }

  static Future<List<ParcelModel>> getDataForPdf(
    DateTimeRange? dateTimeRange,
    String driverId,
    String bookingStatus,
    String selectTimeStatus,
  ) async {
    List<ParcelModel> parcelModelList = [];

    try {
      Query query = fireStore.collection(CollectionName.parcelRide);

      if (bookingStatus != 'All') {
        query = query.where('bookingStatus', isEqualTo: bookingStatus);
      }

      if (driverId != 'All') {
        query = query.where('driverId', isEqualTo: driverId);
      }

      if (selectTimeStatus != 'All' && dateTimeRange != null) {
        query = query.where('createAt', isGreaterThanOrEqualTo: dateTimeRange.start).where('createAt', isLessThanOrEqualTo: dateTimeRange.end);
      }

      query = query.orderBy('createAt', descending: true);

      QuerySnapshot querySnapshot = await query.get();

      for (var element in querySnapshot.docs) {
        ParcelModel bookingModel = ParcelModel.fromJson(element.data() as Map<String, dynamic>);
        parcelModelList.add(bookingModel);
      }
    } catch (error) {
      log('Error fetching PDF cab data: $error');
    }

    return parcelModelList;
  }

  static Future<List<IntercityModel>> getDataForPdfInterCity(
    DateTimeRange? dateTimeRange,
    String driverId,
    String bookingStatus,
    String selectTimeStatus,
  ) async {
    List<IntercityModel> interCityModelList = [];
    try {
      Query query = fireStore.collection(CollectionName.interCityRide);

      if (bookingStatus != 'All') {
        query = query.where('bookingStatus', isEqualTo: bookingStatus);
      }

      if (driverId != 'All') {
        query = query.where('driverId', isEqualTo: driverId);
      }

      if (selectTimeStatus != 'All' && dateTimeRange != null) {
        query = query.where('createAt', isGreaterThanOrEqualTo: dateTimeRange.start).where('createAt', isLessThanOrEqualTo: dateTimeRange.end);
      }

      query = query.orderBy('createAt', descending: true);

      QuerySnapshot querySnapshot = await query.get();

      for (var element in querySnapshot.docs) {
        IntercityModel bookingModel = IntercityModel.fromJson(element.data() as Map<String, dynamic>);
        interCityModelList.add(bookingModel);
      }
    } catch (error) {
      log('Error fetching PDF cab data: $error');
    }

    return interCityModelList;
  }

  static Future<List<BookingModel>> getDataForPdfCab(
    DateTimeRange? dateTimeRange,
    String driverId,
    String bookingStatus,
    String selectTimeStatus,
  ) async {
    List<BookingModel> cabModelList = [];

    try {
      Query query = fireStore.collection(CollectionName.bookings);

      if (bookingStatus != 'All') {
        query = query.where('bookingStatus', isEqualTo: bookingStatus);
      }

      if (driverId != 'All') {
        query = query.where('driverId', isEqualTo: driverId);
      }

      if (selectTimeStatus != 'All' && dateTimeRange != null) {
        query = query.where('createAt', isGreaterThanOrEqualTo: dateTimeRange.start).where('createAt', isLessThanOrEqualTo: dateTimeRange.end);
      }

      query = query.orderBy('createAt', descending: true);

      QuerySnapshot querySnapshot = await query.get();

      for (var element in querySnapshot.docs) {
        BookingModel bookingModel = BookingModel.fromJson(element.data() as Map<String, dynamic>);
        cabModelList.add(bookingModel);
      }
    } catch (error) {
      log('Error fetching PDF cab data: $error');
    }

    return cabModelList;
  }

  static Future<List<SubscriptionHistoryModel>> dataForSubscriptionHistoryPdf(
    DateTimeRange? dateTimeRange,
    String driverId,
    String selectTimeStatus,
  ) async {
    List<SubscriptionHistoryModel> subscriptionHistoryList = [];

    try {
      Query query = fireStore.collection(CollectionName.subscriptionHistory);

      if (driverId != 'All') {
        query = query.where('driverId', isEqualTo: driverId);
      }

      if (selectTimeStatus != 'All' && dateTimeRange != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: dateTimeRange.start).where('createdAt', isLessThanOrEqualTo: dateTimeRange.end);
      }

      query = query.orderBy('createdAt', descending: true);
      QuerySnapshot querySnapshot = await query.get();
      for (var element in querySnapshot.docs) {
        SubscriptionHistoryModel subScriptionModel = SubscriptionHistoryModel.fromJson(element.data() as Map<String, dynamic>);
        subscriptionHistoryList.add(subScriptionModel);
      }
    } catch (error) {
      log('Error fetching PDF cab data: $error');
    }

    return subscriptionHistoryList;
  }

  static Future<List<RentalBookingModel>> getDataForRentalRidePdf(
    DateTimeRange? dateTimeRange,
    String driverId,
    String bookingStatus,
    String selectTimeStatus,
  ) async {
    List<RentalBookingModel> cabModelList = [];

    try {
      Query query = fireStore.collection(CollectionName.rentalRide);

      if (bookingStatus != 'All') {
        query = query.where('bookingStatus', isEqualTo: bookingStatus);
      }

      if (driverId != 'All') {
        query = query.where('driverId', isEqualTo: driverId);
      }

      if (selectTimeStatus != 'All' && dateTimeRange != null) {
        query = query.where('createAt', isGreaterThanOrEqualTo: dateTimeRange.start).where('createAt', isLessThanOrEqualTo: dateTimeRange.end);
      }

      query = query.orderBy('createAt', descending: true);

      QuerySnapshot querySnapshot = await query.get();

      for (var element in querySnapshot.docs) {
        RentalBookingModel bookingModel = RentalBookingModel.fromJson(element.data() as Map<String, dynamic>);
        cabModelList.add(bookingModel);
      }
    } catch (error) {
      log('Error fetching PDF cab data: $error');
    }

    return cabModelList;
  }

  static Future<List<BookingModel>> getRecentBooking(String? status) async {
    try {
      final snap = await fireStore.collection(CollectionName.bookings).orderBy('createAt', descending: true).get();
      return snap.docs.map((doc) => BookingModel.fromJson(doc.data())).toList();
    } catch (error) {
      log('Error in get booking history: $error');
      return [];
    }
  }

  static Future<List<BookingModel>> getBookingByUserId(String? status, String? userId) async {
    try {
      Query query = fireStore.collection(CollectionName.bookings).where('customerId', isEqualTo: userId);
      if (status != 'All') {
        query = query.where('bookingStatus', isEqualTo: status);
      }
      final snap = await query.orderBy('createAt', descending: true).get();
      return snap.docs.map((doc) => BookingModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (error) {
      log('Error in get booking history: $error');
      return [];
    }
  }

  static Future<bool> updatePayoutRequest(WithdrawModel payoutRequestModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.withDrawHistory).doc(payoutRequestModel.id).update(payoutRequestModel.toJson());
      ShowToastDialog.successToast("Save Payout Request...!");
      return true;
    } catch (error) {
      log('Error in update payout request: $error');
      return false;
    }
  }

  static Future<bool> updateVehicleType(VehicleTypeModel vehicleTypeModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.vehicleType).doc(vehicleTypeModel.id).update(vehicleTypeModel.toJson());
      ShowToastDialog.successToast("Save VehicleType...!");
      return true;
    } catch (error) {
      return false;
    }
  }

  static Future<List<CouponModel>> getCoupon() async {
    try {
      final snap = await fireStore.collection(CollectionName.coupon).get();
      return snap.docs.map((doc) => CouponModel.fromJson(doc.data())).toList();
    } catch (error) {
      log('Error fetching coupons: $error');
      return [];
    }
  }

  static Future<bool> addCoupon(CouponModel couponModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.coupon).doc(couponModel.id).set(couponModel.toJson());
      ShowToastDialog.successToast("Save Coupon...!");
      return true;
    } catch (error) {
      return false;
    }
  }

  static Future<bool> updateCoupon(CouponModel couponModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.coupon).doc(couponModel.id).update(couponModel.toJson());
      ShowToastDialog.successToast("Save Coupon...!");
      return true;
    } catch (error) {
      return false;
    }
  }

  static Future<bool> updateZone(ZoneModel zoneModel) {
    return FirebaseFirestore.instance.collection(CollectionName.zones).doc(zoneModel.id).update(zoneModel.toJson()).then(
      (value) {
        return true;
      },
    ).catchError((error) {
      return false;
    });
  }

  static Future<bool> updateDocument(DocumentsModel documentModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.documents).doc(documentModel.id).update(documentModel.toJson());
      ShowToastDialog.successToast("Save Document...!");
      return true;
    } catch (error) {
      return false;
    }
  }

  static Future<bool> setWalletTransaction(WalletTransactionModel walletTransactionModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.walletTransaction).doc(walletTransactionModel.id).set(walletTransactionModel.toJson());
      return true;
    } catch (error) {
      log("Failed to update user: $error");
      return false;
    }
  }

  static Future<bool> updateUserWallet({required String amount, required String userId}) async {
    try {
      final user = await getUserByUserID(userId);
      if (user == null) return false;
      final newAmount = (double.parse(user.walletAmount.toString()) + double.parse(amount)).toString();
      user.walletAmount = newAmount;
      return await updateUsers(user);
    } catch (e) {
      log('Error updating user wallet: $e');
      return false;
    }
  }

  static Future<bool> updateDriverWallet({required String amount, required String userId}) async {
    try {
      final driver = await getDriverByDriverID(userId);
      if (driver == null) return false;
      final newAmount = (double.parse(driver.walletAmount.toString()) + double.parse(amount)).toString();
      driver.walletAmount = newAmount;
      return await updateDriver(driver);
    } catch (e) {
      log('Error updating driver wallet: $e');
      return false;
    }
  }

  static Future<UserModel?> getCustomerByCustomerID(String id) async {
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.users).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return UserModel(fullName: "Unknown User", phoneNumber: "N/A", countryCode: "");
    } catch (e) {
      log('Error fetching customer: $e');
      return null;
    }
  }

  static Future<bool> updateUsers(UserModel userModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.users).doc(userModel.id).update(userModel.toJson());
      return true;
    } catch (e) {
      log('Error updating user: $e');
      return false;
    }
  }

  static Future<List<WalletTransactionModel>> getWalletTransactionOfUser(String? userid, String? type) async {
    try {
      final snap = await fireStore
          .collection(CollectionName.walletTransaction)
          .where('userId', isEqualTo: userid)
          .where('type', isEqualTo: type)
          .orderBy('createdDate', descending: true)
          .get();
      return snap.docs.map((doc) => WalletTransactionModel.fromJson(doc.data())).toList();
    } catch (e) {
      log('Error fetching wallet transactions: $e');
      return [];
    }
  }

  static Future<bool> addSupportReason(SupportReasonModel supportReasonModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.supportReason).doc(supportReasonModel.id).set(supportReasonModel.toJson());
      ShowToastDialog.successToast("Support Reason Saved...!".tr);
      return true;
    } catch (e) {
      ShowToastDialog.errorToast("Something went wrong".tr);
      return false;
    }
  }

  static Future<List<SupportReasonModel>> getSupportReason() async {
    try {
      final snap = await fireStore.collection(CollectionName.supportReason).get();
      return snap.docs.map((doc) => SupportReasonModel.fromJson(doc.data())).toList();
    } catch (error) {
      log('Error fetching support reasons: $error');
      return [];
    }
  }

  static Future<bool> updateSupportReason(SupportReasonModel supportReasonModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.supportReason).doc(supportReasonModel.id).update(supportReasonModel.toJson());
      ShowToastDialog.successToast("Support Reason Updated...!".tr);
      return true;
    } catch (error) {
      ShowToastDialog.errorToast("Something went wrong".tr);
      return false;
    }
  }

  static Future<List<SupportTicketModel>> getSupportTicket() async {
    try {
      final snap = await fireStore.collection(CollectionName.supportTicket).orderBy("createAt", descending: true).get();
      return snap.docs.map((doc) => SupportTicketModel.fromJson(doc.data())).toList();
    } catch (error) {
      log('Error fetching support tickets: $error');
      return [];
    }
  }

  static Future<List<UserModel>> dataForCustomerPdf(DateTimeRange? dateTimeRange) async {
    try {
      final snap = await fireStore
          .collection(CollectionName.users)
          .where('createdAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
    } catch (error) {
      log('Error fetching customer history: $error');
      return [];
    }
  }

  static Future<List<DriverUserModel>> dataForDriverPdf(DateTimeRange? dateTimeRange) async {
    try {
      final snap = await fireStore
          .collection(CollectionName.drivers)
          .where('createdAt', isGreaterThanOrEqualTo: dateTimeRange!.start, isLessThanOrEqualTo: dateTimeRange.end)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map((doc) => DriverUserModel.fromJson(doc.data())).toList();
    } catch (error) {
      log('Error fetching driver history: $error');
      return [];
    }
  }

  static Future<List<WithdrawModel>> dataForPayoutRequestPdf(
    DateTimeRange? dateTimeRange,
    String driverId,
    String bookingStatus,
    String selectTimeStatus,
  ) async {
    try {
      Query query = fireStore.collection(CollectionName.withDrawHistory);

      if (bookingStatus != 'All') {
        query = query.where('paymentStatus', isEqualTo: bookingStatus);
      }
      if (driverId != 'All') {
        query = query.where('driverId', isEqualTo: driverId);
      }
      if (selectTimeStatus != 'All' && dateTimeRange != null) {
        query = query.where('createdDate', isGreaterThanOrEqualTo: dateTimeRange.start).where('createdDate', isLessThanOrEqualTo: dateTimeRange.end);
      }
      query = query.orderBy('createdDate', descending: true);

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => WithdrawModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (error) {
      log('Error fetching payout request PDF data: $error');
      return [];
    }
  }

  static Future<List<SubscriptionModel>> getSubscription() async {
    try {
      final snap = await FirebaseFirestore.instance.collection(CollectionName.subscriptionPlans).get();
      return snap.docs.map((doc) => SubscriptionModel.fromJson(doc.data())).toList();
    } catch (error) {
      log('Error fetching subscriptions: $error');
      return [];
    }
  }

  static Future<bool> updateSubscription(SubscriptionModel subscriptionModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.subscriptionPlans).doc(subscriptionModel.id).update(subscriptionModel.toJson());
      return true;
    } catch (error) {
      log('Error updating subscription: $error');
      return false;
    }
  }

  static Future<bool> addSubscription(SubscriptionModel subscriptionModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.subscriptionPlans).doc(subscriptionModel.id).set(subscriptionModel.toJson());
      return true;
    } catch (error) {
      log('Error adding subscription: $error');
      return false;
    }
  }

  static Future<BookingModel?> getBookingByBookingId(String bookingId) async {
    BookingModel? bookingModel;
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.bookings).doc(bookingId).get();
      if (doc.exists) {
        bookingModel = BookingModel.fromJson(doc.data()!);
      } else {
        bookingModel = BookingModel();
      }
    } catch (error) {
      return null;
    }
    return bookingModel;
  }

  static Future<IntercityModel?> getInterCityBookingById(String bookingId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.interCityRide).doc(bookingId).get();

      if (doc.exists && doc.data() != null) {
        return IntercityModel.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint('Error in getInterCityBookingById: $e');
      debugPrint('StackTrace: $stackTrace');
      return null;
    }
  }

  static Future<ParcelModel?> getParcelBookingById(String driverId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.parcelRide).doc(driverId).get();

      if (doc.exists && doc.data() != null) {
        return ParcelModel.fromJson(doc.data()!..addAll({'id': doc.id}));
      }
      return null;
    } catch (e) {
      debugPrint("Error in getDriverByDriverID: $e");
      return null;
    }
  }

  static Future<RentalBookingModel?> getRentalRideByBookingId(String bookingId) async {
    RentalBookingModel? bookingModel;
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.rentalRide).doc(bookingId).get();
      if (doc.exists) {
        bookingModel = RentalBookingModel.fromJson(doc.data()!);
      } else {
        bookingModel = RentalBookingModel();
      }
    } catch (error) {
      return null;
    }
    return bookingModel;
  }

  static Future<ZoneModel?> getZoneByZoneId(String bookingId) async {
    ZoneModel? zoneModel;
    try {
      final doc = await FirebaseFirestore.instance.collection(CollectionName.zones).doc(bookingId).get();
      if (doc.exists) {
        zoneModel = ZoneModel.fromJson(doc.data()!);
      } else {
        zoneModel = ZoneModel();
      }
    } catch (error) {
      return null;
    }
    return zoneModel;
  }

  static Future<List<PushNotificationModel>> getPushNotification() async {
    List<PushNotificationModel> notificationModel = [];
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance.collection(CollectionName.notificationFromAdmin).orderBy("createdAt", descending: true).get();
      for (var document in snap.docs) {
        Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
        if (data != null) {
          notificationModel.add(PushNotificationModel.fromJson(data));
        }
      }
    } catch (e) {
      developer.log("Error in notification: $e");
    }
    return notificationModel;
  }

  static Future<bool> addPushNotification(PushNotificationModel notificationModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.notificationFromAdmin).doc(notificationModel.id).set(notificationModel.toJson());
      return true;
    } catch (e) {
      developer.log("Error in add notification: $e");
      return false;
    }
  }

  static Future<List<LoyaltyPointTransactionModel>?> getLoyaltyPointTransactionByCustomer(String customerId) async {
    final loyaltyPointTransactionModelList = <LoyaltyPointTransactionModel>[];
    try {
      final value = await fireStore.collection(CollectionName.loyaltyPointHistory).where('customerId', isEqualTo: customerId).orderBy('createdAt', descending: true).get();
      for (var doc in value.docs) {
        loyaltyPointTransactionModelList.add(
          LoyaltyPointTransactionModel.fromJson(doc.data()),
        );
      }
    } catch (error) {
      log("Error fetching loyalty transactions: $error");
    }
    return loyaltyPointTransactionModelList;
  }

  static Future<List<EmailTemplateModel>> getEmailTemplate() async {
    try {
      final snap = await FirebaseFirestore.instance.collection(CollectionName.emailTemplate).get();
      return snap.docs.map((doc) => EmailTemplateModel.fromJson(doc.data())).toList();
    } catch (error) {
      log('Error fetching Email Template: $error');
      return [];
    }
  }

  static Future<bool> updateEmailTemplate(EmailTemplateModel templateModel) async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.emailTemplate).doc(templateModel.id).update(templateModel.toJson());
      return true;
    } catch (error) {
      log('Error updating Email Template: $error');
      return false;
    }
  }

  static Future<bool?> setNotification(NotificationModel notificationModel) async {
    try {
      await fireStore.collection(CollectionName.notification).doc(notificationModel.id).set(notificationModel.toJson());
      return true;
    } catch (error) {
      log("Failed to update user: $error");
      return false;
    }
  }

  static Future<EmergencyContactModel?> getEmergencyContactById({
    required String ownerId,
    required String contactId,
    required String ownerType, // customer | driver
  }) async {
    try {
      final String parentCollection = ownerType == "customer" ? CollectionName.users : CollectionName.drivers;

      final doc = await FirebaseFirestore.instance.collection(parentCollection).doc(ownerId).collection('emergency_contacts').doc(contactId).get();

      if (doc.exists && doc.data() != null) {
        return EmergencyContactModel.fromJson(doc.data()!);
      }

      return EmergencyContactModel(
        id: contactId,
        name: "Unknown",
        phoneNumber: "N/A",
        countryCode: "",
      );
    } catch (e) {
      log('Error fetching emergency contact: $e');
      return null;
    }
  }

  static Future<void> updateDriverDocumentVerification({
    required String driverId,
    required String documentId,
    required bool isVerify,
  }) async {
    final driverRef = fireStore.collection(CollectionName.drivers).doc(driverId);

    final snapshot = await driverRef.get();

    if (!snapshot.exists) return;

    List documents = snapshot.get("verifyDocument");

    for (int i = 0; i < documents.length; i++) {
      if (documents[i]["documentId"] == documentId) {
        documents[i]["isVerify"] = isVerify;
        break;
      }
    }

    await driverRef.update({"verifyDocument": documents});
  }
}
