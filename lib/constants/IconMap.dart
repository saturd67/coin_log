import 'dart:core';

import 'package:flutter/material.dart';

enum IconCategory {
  food(name: "food", value: "Food"),
  entertainment(name: "entertainment", value: "Entertainment"),
  shopping(name: "shopping", value: "Shopping"),
  transportation(name: "transportation", value: "Transportation"),
  life(name: "life", value: "Life"),
  finance(name: "finance", value: "Finance"),
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
  "restaurant": CoinLogIcon(category: IconCategory.food, name: "Restaurant", iconData: Icons.restaurant),
  "flatware": CoinLogIcon(category: IconCategory.food, name: "Flatware", iconData: Icons.flatware),
  "burger": CoinLogIcon(category: IconCategory.food, name: "Local Dining", iconData: Icons.local_dining),
  "brunch_dining": CoinLogIcon(category: IconCategory.food, name: "Brunch Dining", iconData: Icons.brunch_dining),
  "dining": CoinLogIcon(category: IconCategory.food, name: "Dining", iconData: Icons.dining),
  "local_cafe": CoinLogIcon(category: IconCategory.food, name: "Local Cafe", iconData: Icons.local_cafe),
  "coffee": CoinLogIcon(category: IconCategory.food, name: "Coffee", iconData: Icons.coffee),
  "fastfood": CoinLogIcon(category: IconCategory.food, name: "Fast Food", iconData: Icons.fastfood),
  "lunch_dining": CoinLogIcon(category: IconCategory.food, name: "Lunch Dining", iconData: Icons.lunch_dining),
  "local_pizza": CoinLogIcon(category: IconCategory.food, name: "Pizza", iconData: Icons.local_pizza),
  "liquor": CoinLogIcon(category: IconCategory.food, name: "Liquor", iconData: Icons.liquor),
  "local_bar": CoinLogIcon(category: IconCategory.food, name: "Local Bar", iconData: Icons.local_bar),
  "wine_bar": CoinLogIcon(category: IconCategory.food, name: "Wine Bar", iconData: Icons.wine_bar),
  "sports_bar": CoinLogIcon(category: IconCategory.food, name: "Sports Bar", iconData: Icons.sports_bar),
  "icecream": CoinLogIcon(category: IconCategory.food, name: "Ice Cream", iconData: Icons.icecream),
  "local_drink": CoinLogIcon(category: IconCategory.food, name: "Local Drink", iconData: Icons.local_drink),
  "bakery_dining": CoinLogIcon(category: IconCategory.food, name: "Bakery Dining", iconData: Icons.bakery_dining),
  "cake": CoinLogIcon(category: IconCategory.food, name: "Cake", iconData: Icons.cake),
  "ramen_dining": CoinLogIcon(category: IconCategory.food, name: "Ramen Dining", iconData: Icons.ramen_dining),
  "set_meal": CoinLogIcon(category: IconCategory.food, name: "Set Meal", iconData: Icons.set_meal),

  "local_grocery_store": CoinLogIcon(category: IconCategory.shopping, name: "Grocery Store", iconData: Icons.local_grocery_store),
  "shopping_cart": CoinLogIcon(category: IconCategory.shopping, name: "Shopping Cart", iconData: Icons.shopping_cart),
  "add_shopping_cart": CoinLogIcon(category: IconCategory.shopping, name: "Add to Cart", iconData: Icons.add_shopping_cart),
  "shopping_basket": CoinLogIcon(category: IconCategory.shopping, name: "Basket", iconData: Icons.shopping_basket),
  "storefront": CoinLogIcon(category: IconCategory.shopping, name: "Storefront", iconData: Icons.storefront),
  "store": CoinLogIcon(category: IconCategory.shopping, name: "Store", iconData: Icons.store),
  "local_mall": CoinLogIcon(category: IconCategory.shopping, name: "Mall", iconData: Icons.local_mall),
  "shopping_bag": CoinLogIcon(category: IconCategory.shopping, name: "Shopping Bag", iconData: Icons.shopping_bag),
  "checkroom": CoinLogIcon(category: IconCategory.shopping, name: "Checkroom", iconData: Icons.checkroom),
  "dry_cleaning": CoinLogIcon(category: IconCategory.shopping, name: "Dry Cleaning", iconData: Icons.dry_cleaning),
  "delivery_dining": CoinLogIcon(category: IconCategory.shopping, name: "Food Delivery", iconData: Icons.delivery_dining),
  "takeout_dining": CoinLogIcon(category: IconCategory.shopping, name: "Takeout Dining", iconData: Icons.takeout_dining),
  "production_quantity_limits": CoinLogIcon(category: IconCategory.shopping, name: "Out of Stock", iconData: Icons.production_quantity_limits),
  "receipt_long": CoinLogIcon(category: IconCategory.shopping, name: "Receipt Long", iconData: Icons.receipt_long),
  "receipt": CoinLogIcon(category: IconCategory.shopping, name: "Receipt", iconData: Icons.receipt),
  "point_of_sale": CoinLogIcon(category: IconCategory.shopping, name: "Point of Sale", iconData: Icons.point_of_sale),
  "shopping_bag_outlined": CoinLogIcon(category: IconCategory.shopping, name: "Shopping Bag", iconData: Icons.shopping_bag_outlined),


  "directions_car": CoinLogIcon(category: IconCategory.transportation, name: "Car", iconData: Icons.directions_car),
  "electric_car": CoinLogIcon(category: IconCategory.transportation, name: "Electric Car", iconData: Icons.electric_car),
  "directions_bus": CoinLogIcon(category: IconCategory.transportation, name: "Bus", iconData: Icons.directions_bus),
  "directions_subway": CoinLogIcon(category: IconCategory.transportation, name: "Subway", iconData: Icons.directions_subway),
  "train": CoinLogIcon(category: IconCategory.transportation, name: "Train", iconData: Icons.train),
  "airport_shuttle": CoinLogIcon(category: IconCategory.transportation, name: "Shuttle", iconData: Icons.airport_shuttle),
  "commute": CoinLogIcon(category: IconCategory.transportation, name: "Commute", iconData: Icons.commute),
  "directions_bike": CoinLogIcon(category: IconCategory.transportation, name: "Bicycle", iconData: Icons.directions_bike),
  "directions_boat": CoinLogIcon(category: IconCategory.transportation, name: "Boat", iconData: Icons.directions_boat),
  "flight_takeoff": CoinLogIcon(category: IconCategory.transportation, name: "Flight", iconData: Icons.flight_takeoff),

  "movie": CoinLogIcon(category: IconCategory.entertainment, name: "Movie", iconData: Icons.movie),
  "theaters": CoinLogIcon(category: IconCategory.entertainment, name: "Theaters", iconData: Icons.theaters),
  "live_tv": CoinLogIcon(category: IconCategory.entertainment, name: "Live TV", iconData: Icons.live_tv),
  "tv": CoinLogIcon(category: IconCategory.entertainment, name: "Television", iconData: Icons.tv),
  "music_note": CoinLogIcon(category: IconCategory.entertainment, name: "Music Note", iconData: Icons.music_note),
  "music_video": CoinLogIcon(category: IconCategory.entertainment, name: "Music Video", iconData: Icons.music_video),
  "headphones": CoinLogIcon(category: IconCategory.entertainment, name: "Headphones", iconData: Icons.headphones),
  "radio": CoinLogIcon(category: IconCategory.entertainment, name: "Radio", iconData: Icons.radio),
  "videogame_asset": CoinLogIcon(category: IconCategory.entertainment, name: "Video Game", iconData: Icons.videogame_asset),
  "sports_esports": CoinLogIcon(category: IconCategory.entertainment, name: "Esports", iconData: Icons.sports_esports),
  "sports_soccer": CoinLogIcon(category: IconCategory.entertainment, name: "Soccer", iconData: Icons.sports_soccer),
  "sports_basketball": CoinLogIcon(category: IconCategory.entertainment, name: "Basketball", iconData: Icons.sports_basketball),
  "sports_tennis": CoinLogIcon(category: IconCategory.entertainment, name: "Tennis", iconData: Icons.sports_tennis),
  "sports_baseball": CoinLogIcon(category: IconCategory.entertainment, name: "Baseball", iconData: Icons.sports_baseball),
  "sports_football": CoinLogIcon(category: IconCategory.entertainment, name: "Football", iconData: Icons.sports_football),
  "sports_volleyball": CoinLogIcon(category: IconCategory.entertainment, name: "Volleyball", iconData: Icons.sports_volleyball),
  "sports_cricket": CoinLogIcon(category: IconCategory.entertainment, name: "Cricket", iconData: Icons.sports_cricket),
  "sports_mma": CoinLogIcon(category: IconCategory.entertainment, name: "MMA", iconData: Icons.sports_mma),
  "sports_kabaddi": CoinLogIcon(category: IconCategory.entertainment, name: "Kabaddi", iconData: Icons.sports_kabaddi),
  "sports_motorsports": CoinLogIcon(category: IconCategory.entertainment, name: "Motorsports", iconData: Icons.sports_motorsports),
  "sports_golf": CoinLogIcon(category: IconCategory.entertainment, name: "Golf", iconData: Icons.sports_golf),
  "sports_hockey": CoinLogIcon(category: IconCategory.entertainment, name: "Hockey", iconData: Icons.sports_hockey),
  "sports": CoinLogIcon(category: IconCategory.entertainment, name: "Sports", iconData: Icons.sports),
  "sports_bar": CoinLogIcon(category: IconCategory.entertainment, name: "Sports Bar", iconData: Icons.sports_bar),
  "celebration": CoinLogIcon(category: IconCategory.entertainment, name: "Celebration", iconData: Icons.celebration),
  "festival": CoinLogIcon(category: IconCategory.entertainment, name: "Festival", iconData: Icons.festival),
  "mic": CoinLogIcon(category: IconCategory.entertainment, name: "Microphone", iconData: Icons.mic),
  "movie_filter": CoinLogIcon(category: IconCategory.entertainment, name: "Movie Filter", iconData: Icons.movie_filter),
  "slideshow": CoinLogIcon(category: IconCategory.entertainment, name: "Slideshow", iconData: Icons.slideshow),
  "photo_camera": CoinLogIcon(category: IconCategory.entertainment, name: "Photo Camera", iconData: Icons.photo_camera),
  "camera_roll": CoinLogIcon(category: IconCategory.entertainment, name: "Camera Roll", iconData: Icons.camera_roll),
  "local_play": CoinLogIcon(category: IconCategory.entertainment, name: "Local Play", iconData: Icons.local_play),
  "star": CoinLogIcon(category: IconCategory.entertainment, name: "Star", iconData: Icons.star),
  "attractions": CoinLogIcon(category: IconCategory.entertainment, name: "Attractions", iconData: Icons.attractions),
  "casino": CoinLogIcon(category: IconCategory.entertainment, name: "Casino", iconData: Icons.casino),
  "nightlife": CoinLogIcon(category: IconCategory.entertainment, name: "Nightlife", iconData: Icons.nightlife),

  "home": CoinLogIcon(category: IconCategory.life, name: "Home", iconData: Icons.home),
  "family_restroom": CoinLogIcon(category: IconCategory.life, name: "Family", iconData: Icons.family_restroom),
  "child_care": CoinLogIcon(category: IconCategory.life, name: "Child Care", iconData: Icons.child_care),
  "pregnant_woman": CoinLogIcon(category: IconCategory.life, name: "Pregnant Woman", iconData: Icons.pregnant_woman),
  "elderly": CoinLogIcon(category: IconCategory.life, name: "Elderly", iconData: Icons.elderly),
  "self_improvement": CoinLogIcon(category: IconCategory.life, name: "Improvement", iconData: Icons.self_improvement),
  "favorite": CoinLogIcon(category: IconCategory.life, name: "Love", iconData: Icons.favorite),
  "favorite_border": CoinLogIcon(category: IconCategory.life, name: "Love (Outline)", iconData: Icons.favorite_border),
  "pets": CoinLogIcon(category: IconCategory.life, name: "Pets", iconData: Icons.pets),
  "eco": CoinLogIcon(category: IconCategory.life, name: "Eco", iconData: Icons.eco),
  "cut": CoinLogIcon(category: IconCategory.life, name: "Cut", iconData: Icons.cut),
  "cleaning": CoinLogIcon(category: IconCategory.life, name: "Cleaning", iconData: Icons.cleaning_services),
  "nature": CoinLogIcon(category: IconCategory.life, name: "Nature", iconData: Icons.nature),
  "nature_people": CoinLogIcon(category: IconCategory.life, name: "Nature People", iconData: Icons.nature_people),
  "spa": CoinLogIcon(category: IconCategory.life, name: "Spa", iconData: Icons.spa),
  "emoji_people": CoinLogIcon(category: IconCategory.life, name: "People", iconData: Icons.emoji_people),
  "emoji_nature": CoinLogIcon(category: IconCategory.life, name: "Nature Mood", iconData: Icons.emoji_nature),
  "emoji_emotions": CoinLogIcon(category: IconCategory.life, name: "Emotions", iconData: Icons.emoji_emotions),
  "sentiment_satisfied": CoinLogIcon(category: IconCategory.life, name: "Satisfied", iconData: Icons.sentiment_satisfied),
  "sentiment_dissatisfied": CoinLogIcon(category: IconCategory.life, name: "Dissatisfied", iconData: Icons.sentiment_dissatisfied),
  "sentiment_very_satisfied": CoinLogIcon(category: IconCategory.life, name: "Very Satisfied", iconData: Icons.sentiment_very_satisfied),
  "sentiment_very_dissatisfied": CoinLogIcon(category: IconCategory.life, name: "Dissatisfied", iconData: Icons.sentiment_very_dissatisfied),
  "health_and_safety": CoinLogIcon(category: IconCategory.life, name: "Health", iconData: Icons.health_and_safety),
  "fitness_center": CoinLogIcon(category: IconCategory.life, name: "Fitness Center", iconData: Icons.fitness_center),
  "volunteer_activism": CoinLogIcon(category: IconCategory.life, name: "Volunteer", iconData: Icons.volunteer_activism),
  "handshake": CoinLogIcon(category: IconCategory.life, name: "Handshake", iconData: Icons.handshake),
  "work": CoinLogIcon(category: IconCategory.life, name: "Work", iconData: Icons.work),
  "school": CoinLogIcon(category: IconCategory.life, name: "School", iconData: Icons.school),
  "beach_access": CoinLogIcon(category: IconCategory.life, name: "Beach Access", iconData: Icons.beach_access),
  "park": CoinLogIcon(category: IconCategory.life, name: "Park", iconData: Icons.park),
  "bedtime": CoinLogIcon(category: IconCategory.life, name: "Bedtime", iconData: Icons.bedtime),
  "waving_hand": CoinLogIcon(category: IconCategory.life, name: "Greeting", iconData: Icons.waving_hand),
  "celebration": CoinLogIcon(category: IconCategory.life, name: "Celebration", iconData: Icons.celebration),
  "cake": CoinLogIcon(category: IconCategory.life, name: "Cake", iconData: Icons.cake),
  "event": CoinLogIcon(category: IconCategory.life, name: "Event", iconData: Icons.event),
  "calendar_today": CoinLogIcon(category: IconCategory.life, name: "Calendar", iconData: Icons.calendar_today),
  "travel_explore": CoinLogIcon(category: IconCategory.life, name: "Explore", iconData: Icons.travel_explore),
  "local_florist": CoinLogIcon(category: IconCategory.life, name: "Florist", iconData: Icons.local_florist),
  "yard": CoinLogIcon(category: IconCategory.life, name: "Yard", iconData: Icons.yard),

  "attach_money": CoinLogIcon(category: IconCategory.finance, name: "Money", iconData: Icons.attach_money),
  "savings": CoinLogIcon(category: IconCategory.finance, name: "Savings", iconData: Icons.savings),
  "trending_up": CoinLogIcon(category: IconCategory.finance, name: "Trending Up", iconData: Icons.trending_up),
  "price_check": CoinLogIcon(category: IconCategory.finance, name: "Price Check", iconData: Icons.price_check),
  "monetization_on": CoinLogIcon(category: IconCategory.finance, name: "Monetization", iconData: Icons.monetization_on),
  "credit_score": CoinLogIcon(category: IconCategory.finance, name: "Credit Score", iconData: Icons.credit_score),
  "account_balance_wallet": CoinLogIcon(category: IconCategory.finance, name: "Wallet", iconData: Icons.account_balance_wallet),
  "account_balance": CoinLogIcon(category: IconCategory.finance, name: "Bank", iconData: Icons.account_balance),
  "add_card": CoinLogIcon(category: IconCategory.finance, name: "Add Card", iconData: Icons.add_card),
  "account_tree": CoinLogIcon(category: IconCategory.finance, name: "Account Tree", iconData: Icons.account_tree),
  "show_chart": CoinLogIcon(category: IconCategory.finance, name: "Chart", iconData: Icons.show_chart),
  "analytics": CoinLogIcon(category: IconCategory.finance, name: "Analytics", iconData: Icons.analytics),
  "auto_graph": CoinLogIcon(category: IconCategory.finance, name: "Auto Graph", iconData: Icons.auto_graph),
  "calculate": CoinLogIcon(category: IconCategory.finance, name: "Calculate", iconData: Icons.calculate),
  "currency_exchange": CoinLogIcon(category: IconCategory.finance, name: "Exchange", iconData: Icons.currency_exchange),
  "trending_flat": CoinLogIcon(category: IconCategory.finance, name: "Stable Income", iconData: Icons.trending_flat),
  "addchart": CoinLogIcon(category: IconCategory.finance, name: "Add Chart", iconData: Icons.addchart),
  "bar_chart": CoinLogIcon(category: IconCategory.finance, name: "Bar Chart", iconData: Icons.bar_chart),
  "payments": CoinLogIcon(category: IconCategory.finance, name: "Payments", iconData: Icons.payments),
  "receipt_long": CoinLogIcon(category: IconCategory.finance, name: "Receipt", iconData: Icons.receipt_long),
  "redeem": CoinLogIcon(category: IconCategory.finance, name: "Redeem", iconData: Icons.redeem),
  "wallet": CoinLogIcon(category: IconCategory.finance, name: "Wallet Alt", iconData: Icons.wallet),
  "price_change": CoinLogIcon(category: IconCategory.finance, name: "Price Change", iconData: Icons.price_change),
  "request_quote": CoinLogIcon(category: IconCategory.finance, name: "Request Quote", iconData: Icons.request_quote),
  "paid": CoinLogIcon(category: IconCategory.finance, name: "Paid", iconData: Icons.paid),
  "account_balance_wallet_rounded": CoinLogIcon(category: IconCategory.finance, name: "Wallet Rounded", iconData: Icons.account_balance_wallet_rounded),


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
  "savings": CoinLogIcon(category: IconCategory.account, name: "Savings", iconData: Icons.savings),
  "account_balance_wallet": CoinLogIcon(category: IconCategory.account, name: "Wallet", iconData: Icons.account_balance_wallet),
  "price_check": CoinLogIcon(category: IconCategory.account, name: "Price Check", iconData: Icons.price_check),
  "price_change": CoinLogIcon(category: IconCategory.account, name: "Price Change", iconData: Icons.price_change),
  "attach_money": CoinLogIcon(category: IconCategory.account, name: "Money", iconData: Icons.attach_money),
  "currency_exchange": CoinLogIcon(category: IconCategory.account, name: "Exchange", iconData: Icons.currency_exchange),
  "account_circle": CoinLogIcon(category: IconCategory.account, name: "Account", iconData: Icons.account_circle),
  "person": CoinLogIcon(category: IconCategory.account, name: "User", iconData: Icons.person),
  "person_outline": CoinLogIcon(category: IconCategory.account, name: "User Outline", iconData: Icons.person_outline),
  "badge": CoinLogIcon(category: IconCategory.account, name: "Badge", iconData: Icons.badge),
  "account_box": CoinLogIcon(category: IconCategory.account, name: "Account Box", iconData: Icons.account_box),
  "payment": CoinLogIcon(category: IconCategory.account, name: "Payment", iconData: Icons.payment),
  "receipt_long": CoinLogIcon(category: IconCategory.account, name: "Receipt", iconData: Icons.receipt_long),
  "receipt": CoinLogIcon(category: IconCategory.account, name: "Receipt Short", iconData: Icons.receipt),
  "qr_code_2": CoinLogIcon(category: IconCategory.account, name: "QR Payment", iconData: Icons.qr_code_2),
  "wallet": CoinLogIcon(category: IconCategory.account, name: "Wallet (Alt)", iconData: Icons.wallet),
  "card_membership": CoinLogIcon(category: IconCategory.account, name: "Membership", iconData: Icons.card_membership),
  "card_giftcard": CoinLogIcon(category: IconCategory.account, name: "Gift Card", iconData: Icons.card_giftcard),
  "redeem": CoinLogIcon(category: IconCategory.account, name: "Redeem", iconData: Icons.redeem),
  "atm": CoinLogIcon(category: IconCategory.account, name: "ATM", iconData: Icons.atm),
  "trending_up": CoinLogIcon(category: IconCategory.account, name: "Trending Up", iconData: Icons.trending_up),
  "trending_down": CoinLogIcon(category: IconCategory.account, name: "Trending Down", iconData: Icons.trending_down),
  "show_chart": CoinLogIcon(category: IconCategory.account, name: "Chart", iconData: Icons.show_chart),
  "insert_chart_outlined": CoinLogIcon(category: IconCategory.account, name: "Chart Outline", iconData: Icons.insert_chart_outlined),
  "pie_chart": CoinLogIcon(category: IconCategory.account, name: "Pie Chart", iconData: Icons.pie_chart),
  "analytics": CoinLogIcon(category: IconCategory.account, name: "Analytics", iconData: Icons.analytics),
  "calculate": CoinLogIcon(category: IconCategory.account, name: "Calculator", iconData: Icons.calculate),
  "account_tree": CoinLogIcon(category: IconCategory.account, name: "Account Tree", iconData: Icons.account_tree),
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