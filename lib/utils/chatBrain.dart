import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class ChatBrain {
  void leaveRoom(BuildContext context, {@required roomId}) {
    firestore.collection('rooms/$roomId/members').get().then((value) {
      if (value.size == 1) {
        // When room has only 1 member
        firestore.collection('rooms').doc(roomId).delete().then((value) {
          auth.currentUser.delete().then((value) {
            Navigator.popUntil(context, ModalRoute.withName('/'));
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
              'text':
                  '${auth.currentUser.uid.substring(0, 6)} has left the room',
              'user': 'system',
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
