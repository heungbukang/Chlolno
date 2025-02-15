import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostDetail extends StatefulWidget {
  final String docId;
  final String title;
  final String detail;

  const PostDetail(
      {Key? key,
      required this.docId,
      required this.title,
      required this.detail})
      : super(key: key);

  @override
  _PostDetailState createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  final _commentController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  late CollectionReference database;
  late CollectionReference commentsDatabase;

  @override
  void initState() {
    super.initState();
    database = FirebaseFirestore.instance.collection('Community');
    commentsDatabase = database.doc(widget.docId).collection("Comments");
  }

  List<Container> _buildListCards(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    final ThemeData theme = Theme.of(context);

    return snapshot.data!.docs.map((DocumentSnapshot document) {
      // DateTime _dateTime = DateTime.parse(document['expirationDate'].toDate().toString());
      return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15.0),
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 30,
              ),
              SizedBox(
                width: 174,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      document['user_id'],
                      style: theme.textTheme.headline6,
                      maxLines: 1,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      document['comment'],
                      style: theme.textTheme.headline6,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            ],
          ));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Widget textSection = Container(
      padding: const EdgeInsets.all(32.0),
      child: Text(
        widget.detail,
        style: const TextStyle(fontSize: 20),
        softWrap: true,
      ),
    );

    Widget _buildTextComposer() {
      return IconTheme(
        data: IconThemeData(color: Theme.of(context).backgroundColor),
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: TextField(
                    controller: _commentController,
                    decoration:
                        const InputDecoration.collapsed(hintText: "Comment"),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      database.doc(widget.docId).collection("Comments").add({
                        'comment': _commentController.text,
                        'user_id': auth.currentUser?.uid,
                      });
                      _commentController.clear();
                    },
                  ),
                )
              ],
            )),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          textSection,
          const Divider(height: 1.0),
          Container(
            padding: const EdgeInsets.only(left: 20.0, top: 10.0),
            child: const Text('Comments', style: TextStyle(fontSize: 17.0),),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: commentsDatabase.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Center(
                      child: Text(''),
                    );
                  default:
                    return ListView(
                        padding: const EdgeInsets.all(16.0),
                        children:
                            _buildListCards(context, snapshot) // Changed code
                        );
                }
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          )
        ],
      ),
    );
  }
}
