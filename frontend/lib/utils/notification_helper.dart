// Helper pour ajouter des notifications automatiques
// Utilisez ceci dans vos providers pour notifier les utilisateurs

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationHelper {
  // Notification pour création de propriété
  static void notifyPropertyCreated(
      BuildContext context, String propertyTitle) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.addNotification(
      'Propriété créée',
      'Votre propriété "$propertyTitle" a été publiée avec succès',
      'create',
    );
  }

  // Notification pour mise à jour de propriété
  static void notifyPropertyUpdated(
      BuildContext context, String propertyTitle) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.addNotification(
      'Propriété mise à jour',
      'Les modifications de "$propertyTitle" ont été enregistrées',
      'update',
    );
  }

  // Notification pour suppression de propriété
  static void notifyPropertyDeleted(
      BuildContext context, String propertyTitle) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.addNotification(
      'Propriété supprimée',
      'La propriété "$propertyTitle" a été supprimée',
      'delete',
    );
  }

  // Notification pour nouveau message
  static void notifyNewMessage(BuildContext context, String senderName) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.addNotification(
      'Nouveau message',
      'Vous avez reçu un message de $senderName',
      'create',
    );
  }

  // Notification pour favori ajouté
  static void notifyFavoriteAdded(BuildContext context, String propertyTitle) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.addNotification(
      'Favori ajouté',
      '"$propertyTitle" a été ajouté à vos favoris',
      'create',
    );
  }

  // Notification pour favori retiré
  static void notifyFavoriteRemoved(
      BuildContext context, String propertyTitle) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.addNotification(
      'Favori retiré',
      '"$propertyTitle" a été retiré de vos favoris',
      'delete',
    );
  }

  // Notification personnalisée
  static void notify(
      BuildContext context, String title, String message, String type) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.addNotification(title, message, type);
  }
}
