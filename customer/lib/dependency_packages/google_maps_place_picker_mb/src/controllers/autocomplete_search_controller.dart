import 'package:customer/dependency_packages/google_maps_place_picker_mb/src/autocomplete_search.dart';
import 'package:flutter/cupertino.dart';

class SearchBarController extends ChangeNotifier {
  late AutoCompleteSearchState _autoCompleteSearch;

  void attach(AutoCompleteSearchState searchWidget) {
    _autoCompleteSearch = searchWidget;
  }

  /// Just clears text.
  void clear() {
    _autoCompleteSearch.clearText();
  }

  /// Clear and remove focus (Dismiss keyboard)
  void reset() {
    _autoCompleteSearch.resetSearchBar();
  }

  void clearOverlay() {
    _autoCompleteSearch.clearOverlay();
  }
}
