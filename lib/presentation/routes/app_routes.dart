import 'package:flutter/material.dart';

import '../../data/models/pet_model.dart';
import '../login/login_page.dart';
import '../login/role_selection_page.dart';
import '../home/home_adoptant_page.dart';
import '../ai_chat/ai_chat_page.dart';
import '../map/map_page.dart';
import '../adoption_requests/adoption_requests_page.dart';
import '../pet_detail/pet_detail_page.dart';

class AppRoutes {
  // nombres de rutas
  static const login = '/login';
  static const roleSelection = '/roles';
  static const home = '/home';
  static const chat = '/chat';
  static const map = '/map';
  static const requests = '/requests';
  static const petDetail = '/pet-detail';

  static Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginPage(),
    roleSelection: (_) => const RoleSelectionPage(),
    home: (_) => const HomeAdoptantPage(),
    chat: (_) => const AiChatPage(),
    map: (_) => const MapPage(),
    requests: (_) => const AdoptionRequestsPage(),
    petDetail: (context) {
      final pet = ModalRoute.of(context)?.settings.arguments as PetModel?;
      return PetDetailPage(pet: pet ?? PetModel.empty());
    },
  };
}
