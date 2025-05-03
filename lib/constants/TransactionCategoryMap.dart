import 'package:flutter/material.dart';

enum CoinLogIconCategory {
  food(name: "food", value: "Food"),
  shopping(name: "shopping", value: "Shopping"),
  transportation(name: "transportation", value: "Transportation"),
  other(name: "other", value: "Other");

  final String name;
  final Object value;

  const CoinLogIconCategory({required this.name, required this.value});

}

Map<String, CoinLogIcon> coinLogIconMap = {
  "lunch_dining": CoinLogIcon(category: CoinLogIconCategory.food, name: "Lunch Dining", icon: Icons.lunch_dining),
  "restaurant": CoinLogIcon(category: CoinLogIconCategory.food, name: "Restaurant", icon: Icons.restaurant),
  "coffee": CoinLogIcon(category: CoinLogIconCategory.food, name: "Coffee", icon: Icons.local_cafe),
  "fastfood": CoinLogIcon(category: CoinLogIconCategory.food, name: "Fast Food", icon: Icons.fastfood),
  "icecream": CoinLogIcon(category: CoinLogIconCategory.food, name: "Ice Cream", icon: Icons.icecream),
  "cake": CoinLogIcon(category: CoinLogIconCategory.food, name: "Cake", icon: Icons.cake),
  "local_bar": CoinLogIcon(category: CoinLogIconCategory.food, name: "Bar", icon: Icons.local_bar),
  "grocery": CoinLogIcon(category: CoinLogIconCategory.food, name: "Grocery", icon: Icons.local_grocery_store),
  "food_bank": CoinLogIcon(category: CoinLogIconCategory.food, name: "Food Bank", icon: Icons.food_bank),
  "bakery_dining": CoinLogIcon(category: CoinLogIconCategory.food, name: "Bakery", icon: Icons.bakery_dining),
  "taco": CoinLogIcon(category: CoinLogIconCategory.food, name: "Taco", icon: Icons.restaurant_menu),
  "burger": CoinLogIcon(category: CoinLogIconCategory.food, name: "Burger", icon: Icons.local_dining),
  "wine_bar": CoinLogIcon(category: CoinLogIconCategory.food, name: "Wine Bar", icon: Icons.wine_bar),
  "local_pizza": CoinLogIcon(category: CoinLogIconCategory.food, name: "Pizza", icon: Icons.local_pizza),

  "shopping_cart": CoinLogIcon(category: CoinLogIconCategory.shopping, name: "Shopping Cart", icon: Icons.shopping_cart),
  "store": CoinLogIcon(category: CoinLogIconCategory.shopping, name: "Store", icon: Icons.store),
  "local_mall": CoinLogIcon(category: CoinLogIconCategory.shopping, name: "Mall", icon: Icons.local_mall),
  "card_giftcard": CoinLogIcon(category: CoinLogIconCategory.shopping, name: "Gift Card", icon: Icons.card_giftcard),
  "add_shopping_cart": CoinLogIcon(category: CoinLogIconCategory.shopping, name: "Add to Cart", icon: Icons.add_shopping_cart),
  "business_center": CoinLogIcon(category: CoinLogIconCategory.shopping, name: "Business", icon: Icons.business_center),
  "credit_card": CoinLogIcon(category: CoinLogIconCategory.shopping, name: "Credit Card", icon: Icons.credit_card),
  "shopping_basket": CoinLogIcon(category: CoinLogIconCategory.shopping, name: "Basket", icon: Icons.shopping_basket),
  "shopping_bag": CoinLogIcon(category: CoinLogIconCategory.shopping, name: "Shopping Bag", icon: Icons.shopping_bag),
  "toys": CoinLogIcon(category: CoinLogIconCategory.shopping, name: "Toys", icon: Icons.toys),
  "clothing": CoinLogIcon(category: CoinLogIconCategory.shopping, name: "Clothing", icon: Icons.checkroom),
  "watch": CoinLogIcon(category: CoinLogIconCategory.shopping, name: "Watch", icon: Icons.watch),
  "sports_esports": CoinLogIcon(category: CoinLogIconCategory.shopping, name: "Electronics", icon: Icons.sports_esports),

  "directions_car": CoinLogIcon(category: CoinLogIconCategory.transportation, name: "Car", icon: Icons.directions_car),
  "directions_bus": CoinLogIcon(category: CoinLogIconCategory.transportation, name: "Bus", icon: Icons.directions_bus),
  "directions_bike": CoinLogIcon(category: CoinLogIconCategory.transportation, name: "Bicycle", icon: Icons.directions_bike),
  "flight_takeoff": CoinLogIcon(category: CoinLogIconCategory.transportation, name: "Flight", icon: Icons.flight_takeoff),
  "train": CoinLogIcon(category: CoinLogIconCategory.transportation, name: "Train", icon: Icons.train),
  "directions_boat": CoinLogIcon(category: CoinLogIconCategory.transportation, name: "Boat", icon: Icons.directions_boat),
  "airport_shuttle": CoinLogIcon(category: CoinLogIconCategory.transportation, name: "Shuttle", icon: Icons.airport_shuttle),
  "directions_subway": CoinLogIcon(category: CoinLogIconCategory.transportation, name: "Subway", icon: Icons.directions_subway),
  "commute": CoinLogIcon(category: CoinLogIconCategory.transportation, name: "Commute", icon: Icons.commute),
  "electric_car": CoinLogIcon(category: CoinLogIconCategory.transportation, name: "Electric Car", icon: Icons.electric_car),
  
  "pets": CoinLogIcon(category: CoinLogIconCategory.other, name: "Pets", icon: Icons.pets),
  "accessibility": CoinLogIcon(category: CoinLogIconCategory.other, name: "Accessibility", icon: Icons.accessibility),
  "alarm": CoinLogIcon(category: CoinLogIconCategory.other, name: "Alarm", icon: Icons.alarm),
  "event": CoinLogIcon(category: CoinLogIconCategory.other, name: "Event", icon: Icons.event),
  "help": CoinLogIcon(category: CoinLogIconCategory.other, name: "Help", icon: Icons.help),
  "info": CoinLogIcon(category: CoinLogIconCategory.other, name: "Information", icon: Icons.info),
  "language": CoinLogIcon(category: CoinLogIconCategory.other, name: "Language", icon: Icons.language),
  "lock": CoinLogIcon(category: CoinLogIconCategory.other, name: "Lock", icon: Icons.lock),
  "location_on": CoinLogIcon(category: CoinLogIconCategory.other, name: "Location", icon: Icons.location_on),
  "notifications": CoinLogIcon(category: CoinLogIconCategory.other, name: "Notifications", icon: Icons.notifications),
  "phone": CoinLogIcon(category: CoinLogIconCategory.other, name: "Phone", icon: Icons.phone),
  "public": CoinLogIcon(category: CoinLogIconCategory.other, name: "Public", icon: Icons.public),
  "settings": CoinLogIcon(category: CoinLogIconCategory.other, name: "Settings", icon: Icons.settings),
  "star": CoinLogIcon(category: CoinLogIconCategory.other, name: "Favorites", icon: Icons.star),
  "visibility": CoinLogIcon(category: CoinLogIconCategory.other, name: "Visibility", icon: Icons.visibility),
};

class CoinLogIcon {
  final CoinLogIconCategory category;
  final String name;
  final IconData icon;

  CoinLogIcon({
    required this.category,
    required this.name,
    required this.icon
  });
}


Map<CoinLogIconCategory, List<Map<String,CoinLogIcon>>> getGroupedIcons() {
  Map<CoinLogIconCategory, List<Map<String,CoinLogIcon>>> groupedIcons = {};
  coinLogIconMap.forEach((key, value) {
    groupedIcons.putIfAbsent(value.category, () => []).add({key: value});
  });
  return groupedIcons;
} 