import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

class UploadImage extends StatefulWidget {
  const UploadImage({Key? key}) : super(key: key);

  @override
  _UploadImageState createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  //
  File? image;
  UploadTask? uploadTask;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //
      appBar: AppBar(
        //
        title: Text('Upload Image'),

        //
        actions: [
          //
          IconButton(
            icon: Icon(Icons.camera),
            onPressed: () {
              //
              getImage();
            },
          ),

          image == null
              ? Container()
              : IconButton(
                  //
                  icon: Icon(Icons.check),
                  onPressed: () {
                    //
                    uploadImage();
                  },
                ),
        ],
      ),
      //
      body: image == null
          ? Center(child: Text('No Image'))
          : ListView(
              children: [
                //
                Image.file(image!),

                SizedBox(height: 16),
                //
                uploadTask == null
                    ? Container()
                    : TaskStatus(uploadTask: uploadTask!),
              ],
            ),
    );
  }

  // to get image
  Future<void> getImage() async {
    //
    var capturedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    //
    if (capturedImage != null) {
      setState(() {
        image = File(capturedImage.path);
        uploadTask = null;
      });
    }
  }

  // to upload image to firebase storage

  Future<void> uploadImage() async {
    // get extension
    String fileExtension = image!.path.split('.').last;

    // get unique file name
    String fileName =
        DateTime.now().microsecondsSinceEpoch.toString() + '.' + fileExtension;

    // to get firebaseStorage reference
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;

    // to create reference in firebase storage
    Reference reference = firebaseStorage.ref('images/$fileName');

    // put file into firebase storage

    uploadTask = reference.putFile(image!);

    setState(() {
      //
    });
  }
}

class TaskStatus extends StatelessWidget {
  //
  final UploadTask uploadTask;

  TaskStatus({required this.uploadTask});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: uploadTask.snapshotEvents,

      //
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        //
        if (!snapshot.hasData) {
          return Container();
        }

        // get data into tasksnapshot
        TaskSnapshot taskSnapshot = snapshot.data;

        //get total byte
        int totalByte = taskSnapshot.totalBytes;

        // get byteTransfered
        int byteTransdered = taskSnapshot.bytesTransferred;

        double percentage = (byteTransdered / totalByte);
        String percent = (percentage * 100).toStringAsFixed(0);
        int per = int.parse(percent);

        return per != 100
            ? Stack(
                alignment: Alignment.center,
                children: [
                  //
                  Container(
                    height: 70,
                    width: 70,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.grey.shade200,
                      strokeWidth: 3.0,
                      value: percentage,
                    ),
                  ),
                  //
                  Text('$percent %')
                ],
              )
            : Center(child: Text('Your Photo is uploaded'));
      },
    );
  }
}
