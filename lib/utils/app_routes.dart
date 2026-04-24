class AppRoutes {
// Rutas auth
  static const String login = '/login';
  static const String register = '/register';

  // Rutas main
  static const String home = '/home';
  static const String profile = '/profile';

  // Rutas tarjetas
  static const String cards = '/cards';
  static const String addCard = '/add-card';

  // Rutas facturación
  static const String billing = '/billing';
  static const String billingHistory = '/billing-history';

  // Rutas OpenPay
  static const String openPay = '/openpay';

  // Rutas de eventos
  static const String eventTickets = '/event-tickets';
  static const String ticketDetail = '/ticket-detail';

  // Constructor privado para evitar instanciación
  AppRoutes._();
}
