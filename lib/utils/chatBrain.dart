import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;
FirebaseStorage storage = FirebaseStorage.instance;

class ChatBrain {
  void leaveRoom(BuildContext context, {@required roomId}) {
    firestore.collection('rooms/$roomId/members').get().then((value) {
      if (value.size == 1) {
        // When room has only 1 member
        firestore.collection('rooms/$roomId/members').get().then((value) {
          value.docs.forEach((element) {
            firestore.doc('rooms/$roomId/members/${element.id}').delete();
          });
        }).then((value) {
          firestore.collection('rooms/$roomId/chats').get().then((value) {
            value.docs.forEach((element) {
              firestore.doc('rooms/$roomId/chats/${element.id}').delete();
            });
          });
        }).then((value) {
          firestore
              .collection('rooms')
              .doc(roomId)
              .delete()
              .then((value) async {
            await storage.ref('images/$roomId/').listAll().then((result) {
              result.items.forEach((element) {
                element.delete();
              });
            });
            auth.currentUser.delete().then((value) {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            });
          });
        });
      } else {
        firestore
            .collection('rooms/$roomId/members')
            .where('uid', isEqualTo: auth.currentUser.uid)
            .get()
            .then((value) {
          firestore
              .doc('/rooms/$roomId/members/${value.docs[0].id}')
              .delete()
              .then((value) {
            firestore.collection('rooms/$roomId/chats').add({
              'type': 'alert',
              'text': '${auth.currentUser.displayName} has left the room',
              'uid': auth.currentUser.uid,
              'username': 'system',
              'createdAt': Timestamp.now(),
            }).then((value) {
              auth.currentUser.delete().then((value) {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              });
            });
          });
        });
      }
    });
  }
}
