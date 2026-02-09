# Data Contracts

## Overview
This document defines Firestore collections, key fields, and read/write ownership expectations for client and admin access.

## Collections

### Core Accounts
- admin
  - Key fields: id
  - Read/Write: Admin only
- users
  - Key fields: id
  - Read: Admin or signed-in users
  - Write: Owner (doc id == auth uid) or admin
- drivers
  - Key fields: id
  - Read: Admin or signed-in users
  - Write: Owner (doc id == auth uid) or admin

### Public Configuration (read-only to clients)
- settings, currencies, vehicle_type, vehicle_brand, vehicle_model, languages, documents, zones, subscription_plans, subscription_history, rental_packages, country_tax, banner, coupon, support_reason, email_template, notification_from_admin
  - Read: Signed-in users
  - Write: Admin only

### Bookings & Rides
- bookings
- intercity_ride
- parcel_ride
- rental_ride
  - Required fields (create): id, customerId, bookingStatus, createAt
  - Required fields (update): id, customerId, bookingStatus, updateAt
  - Read: Admin or owner (customerId/driverId)
  - Write: Owner (customerId or driverId) or admin

### Wallets & Transactions
- wallet_transaction
  - Required fields (create): id, userId, amount, createdDate, type, isCredit
  - Read: Admin or owner (userId)
  - Write: Owner (userId) on create; admin only on update/delete
- withdrawal_history
  - Key fields: id, driverId, amount, createdDate
  - Read: Admin or owner (driverId)
  - Write: Owner on create; admin only on update/delete
- transaction_log
  - Key fields: id, userId/driverId
  - Read: Admin or owner
  - Write: Owner on create; admin only on update/delete
- loyalty_point_transaction
  - Required fields (create): id, customerId, points, createdAt
  - Read: Admin or owner (customerId)
  - Write: Owner on create; admin only on update/delete

### Support & Notifications
- support_ticket
  - Required fields (create): id, userId, title, subject, description, status, type, createAt, updateAt
  - Read: Admin or owner (userId)
  - Write: Owner on create/update; admin full access
- notification
  - Required fields (create): id, createdAt, type
  - Read: Admin or owner (customerId/driverId/senderId)
  - Write: Owner on create/update; admin full access
- sos_alerts
  - Required fields (create): id, createdAt, type, status
  - Read: Admin or owner (userId/driverId)
  - Write: Owner on create; admin update/delete

### Reviews
- review
  - Key fields: id, bookingId, customerId, driverId, type
  - Read: Signed-in users
  - Write: Signed-in users create only; admin update/delete

### Referral
- referral
  - Key fields: userId, referralCode
  - Read: Admin or owner (userId)
  - Write: Owner on create; admin update/delete

### Banking
- bank_details
  - Required fields (create): id, driverID, holderName, accountNumber
  - Read: Admin or owner (driverID)
  - Write: Owner on create/update; admin full access

### Chat
- chat
  - Key fields: senderId, receiverId, participants
  - Read/Write: Admin or participants only
- chat/{uid}/inbox
  - Key fields: id, peerId, lastMessage, timestamp
  - Read/Write: Owner (uid)

### User Subcollections
- users/{uid}/emergency_contacts
  - Required fields: id, name, phoneNumber, countryCode
  - Read/Write: Owner (uid)
- drivers/{uid}/emergency_contacts
  - Required fields: id, name, phoneNumber, countryCode
  - Read/Write: Owner (uid)
- users/{uid}/sharing_persons
  - Required fields: id, name, mobileNumber
  - Read/Write: Owner (uid)
