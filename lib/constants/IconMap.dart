import 'dart:core';

import 'package:flutter/material.dart';

enum IconCategory {
  food(name: "food", value: "Food"),
  shopping(name: "shopping", value: "Shopping"),
  transportation(name: "transportation", value: "Transportation"),
  account(name: "account", value: "Account"),
  other(name: "other", value: "Other");

  final String name;
  final Object value;

  const IconCategory({required this.name, required this.value});
}

class CoinLogIcon {
  final IconCategory category;
  final String name;
  final IconData iconData;

  CoinLogIcon({
    required this.category,
    required this.name,
    required this.iconData
  });
}

Map<String, CoinLogIcon> transactionCategoryIconMap = {
  "lunch_dining": CoinLogIcon(category: IconCategory.food, name: "Lunch Dining", iconData: Icons.lunch_dining),
  "restaurant": CoinLogIcon(category: IconCategory.food, name: "Restaurant", iconData: Icons.restaurant),
  "coffee": CoinLogIcon(category: IconCategory.food, name: "Coffee", iconData: Icons.local_cafe),
  "fastfood": CoinLogIcon(category: IconCategory.food, name: "Fast Food", iconData: Icons.fastfood),
  "icecream": CoinLogIcon(category: IconCategory.food, name: "Ice Cream", iconData: Icons.icecream),
  "cake": CoinLogIcon(category: IconCategory.food, name: "Cake", iconData: Icons.cake),
  "local_bar": CoinLogIcon(category: IconCategory.food, name: "Bar", iconData: Icons.local_bar),
  "grocery": CoinLogIcon(category: IconCategory.food, name: "Grocery", iconData: Icons.local_grocery_store),
  "food_bank": CoinLogIcon(category: IconCategory.food, name: "Food Bank", iconData: Icons.food_bank),
  "bakery_dining": CoinLogIcon(category: IconCategory.food, name: "Bakery", iconData: Icons.bakery_dining),
  "taco": CoinLogIcon(category: IconCategory.food, name: "Taco", iconData: Icons.restaurant_menu),
  "burger": CoinLogIcon(category: IconCategory.food, name: "Burger", iconData: Icons.local_dining),
  "wine_bar": CoinLogIcon(category: IconCategory.food, name: "Wine Bar", iconData: Icons.wine_bar),
  "local_pizza": CoinLogIcon(category: IconCategory.food, name: "Pizza", iconData: Icons.local_pizza),

  "shopping_cart": CoinLogIcon(category: IconCategory.shopping, name: "Shopping Cart", iconData: Icons.shopping_cart),
  "store": CoinLogIcon(category: IconCategory.shopping, name: "Store", iconData: Icons.store),
  "local_mall": CoinLogIcon(category: IconCategory.shopping, name: "Mall", iconData: Icons.local_mall),
  "card_giftcard": CoinLogIcon(category: IconCategory.shopping, name: "Gift Card", iconData: Icons.card_giftcard),
  "add_shopping_cart": CoinLogIcon(category: IconCategory.shopping, name: "Add to Cart", iconData: Icons.add_shopping_cart),
  "business_center": CoinLogIcon(category: IconCategory.shopping, name: "Business", iconData: Icons.business_center),
  "credit_card": CoinLogIcon(category: IconCategory.shopping, name: "Credit Card", iconData: Icons.credit_card),
  "shopping_basket": CoinLogIcon(category: IconCategory.shopping, name: "Basket", iconData: Icons.shopping_basket),
  "shopping_bag": CoinLogIcon(category: IconCategory.shopping, name: "Shopping Bag", iconData: Icons.shopping_bag),
  "toys": CoinLogIcon(category: IconCategory.shopping, name: "Toys", iconData: Icons.toys),
  "clothing": CoinLogIcon(category: IconCategory.shopping, name: "Clothing", iconData: Icons.checkroom),
  "watch": CoinLogIcon(category: IconCategory.shopping, name: "Watch", iconData: Icons.watch),
  "sports_esports": CoinLogIcon(category: IconCategory.shopping, name: "Electronics", iconData: Icons.sports_esports),

  "directions_car": CoinLogIcon(category: IconCategory.transportation, name: "Car", iconData: Icons.directions_car),
  "directions_bus": CoinLogIcon(category: IconCategory.transportation, name: "Bus", iconData: Icons.directions_bus),
  "directions_bike": CoinLogIcon(category: IconCategory.transportation, name: "Bicycle", iconData: Icons.directions_bike),
  "flight_takeoff": CoinLogIcon(category: IconCategory.transportation, name: "Flight", iconData: Icons.flight_takeoff),
  "train": CoinLogIcon(category: IconCategory.transportation, name: "Train", iconData: Icons.train),
  "directions_boat": CoinLogIcon(category: IconCategory.transportation, name: "Boat", iconData: Icons.directions_boat),
  "airport_shuttle": CoinLogIcon(category: IconCategory.transportation, name: "Shuttle", iconData: Icons.airport_shuttle),
  "directions_subway": CoinLogIcon(category: IconCategory.transportation, name: "Subway", iconData: Icons.directions_subway),
  "commute": CoinLogIcon(category: IconCategory.transportation, name: "Commute", iconData: Icons.commute),
  "electric_car": CoinLogIcon(category: IconCategory.transportation, name: "Electric Car", iconData: Icons.electric_car),
  
  "pets": CoinLogIcon(category: IconCategory.other, name: "Pets", iconData: Icons.pets),
  "accessibility": CoinLogIcon(category: IconCategory.other, name: "Accessibility", iconData: Icons.accessibility),
  "alarm": CoinLogIcon(category: IconCategory.other, name: "Alarm", iconData: Icons.alarm),
  "event": CoinLogIcon(category: IconCategory.other, name: "Event", iconData: Icons.event),
  "help": CoinLogIcon(category: IconCategory.other, name: "Help", iconData: Icons.help),
  "info": CoinLogIcon(category: IconCategory.other, name: "Information", iconData: Icons.info),
  "language": CoinLogIcon(category: IconCategory.other, name: "Language", iconData: Icons.language),
  "lock": CoinLogIcon(category: IconCategory.other, name: "Lock", iconData: Icons.lock),
  "location_on": CoinLogIcon(category: IconCategory.other, name: "Location", iconData: Icons.location_on),
  "notifications": CoinLogIcon(category: IconCategory.other, name: "Notifications", iconData: Icons.notifications),
  "phone": CoinLogIcon(category: IconCategory.other, name: "Phone", iconData: Icons.phone),
  "public": CoinLogIcon(category: IconCategory.other, name: "Public", iconData: Icons.public),
  "settings": CoinLogIcon(category: IconCategory.other, name: "Settings", iconData: Icons.settings),
  "star": CoinLogIcon(category: IconCategory.other, name: "Favorites", iconData: Icons.star),
  "visibility": CoinLogIcon(category: IconCategory.other, name: "Visibility", iconData: Icons.visibility),
};

Map<String, CoinLogIcon> accountIconMap = {
  "account_balance": CoinLogIcon(category: IconCategory.account, name: "Bank", iconData: Icons.account_balance),
  "account_balance_wallet_rounded": CoinLogIcon(category: IconCategory.account, name: "Wallet", iconData: Icons.account_balance_wallet_rounded),
  "credit_card": CoinLogIcon(category: IconCategory.account, name: "Card", iconData: Icons.credit_card),
  "monetization_on": CoinLogIcon(category: IconCategory.account, name: "E-Wallet", iconData: Icons.monetization_on),
  "money": CoinLogIcon(category: IconCategory.account, name: "Cash", iconData: Icons.money),
  "phonelink_ring": CoinLogIcon(category: IconCategory.account, name: "E-Wallet", iconData: Icons.phonelink_ring),
};

IconData getTransactionCategoryIconData(String? iconKey) {
  if (transactionCategoryIconMap[iconKey] != null) {
    return transactionCategoryIconMap[iconKey]!.iconData;
  }
  return Icons.image_not_supported;
}

IconData getAccountIconData(String iconKey) {
  if (accountIconMap[iconKey] != null) {
    return accountIconMap[iconKey]!.iconData;
  }
  return Icons.image_not_supported;
}

Map<IconCategory, List<Map<String,CoinLogIcon>>> getGroupedIcons(Map<String, CoinLogIcon> coinLogIconMap) {
  Map<IconCategory, List<Map<String,CoinLogIcon>>> groupedIcons = {};
  coinLogIconMap.forEach((key, value) {
    groupedIcons.putIfAbsent(value.category, () => []).add({key: value});
  });
  return groupedIcons;
}