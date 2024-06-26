import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cv_builder_admin/provider/image_provider.dart';
import 'package:cv_builder_admin/provider/save_data_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../helper/button_loading_widget.dart';
import '../helper/button_widget.dart';
import '../helper/custom_textfield.dart';
import '../helper/text_widget.dart';
import '../provider/value_provider.dart';
import '../utils/notification_widget.dart';
import 'component/header.dart';

class AdminDashboardMessageScreen extends StatefulWidget {
  AdminDashboardMessageScreen({super.key});

  @override
  State<AdminDashboardMessageScreen> createState() => _AdminDashboardMessageScreenState();
}

class _AdminDashboardMessageScreenState extends State<AdminDashboardMessageScreen> {
  String? _token;
  Stream<String>? _tokenStream;

  int? length;
  String? selectedValue;
  String? dropValue ;
  StreamController categoryListController = StreamController();

  notificationFunctions() async {
    await getPermissionNotification();

    await pushNotificationMessageListner();

    await FirebaseMessaging.instance.getToken().then(setToken);
    _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream!.listen(setToken);
  }

  @override
  Widget build(BuildContext context) {
    //  notificationFunctions();
    return Scaffold(
      backgroundColor: Color(0xffd2dae0),
      body: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Header(),
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(9.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 400.0,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blueGrey),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none
                                  ),
                                  hintText: "Enter Name",
                                ),
                              ),
                            ),
                            SizedBox(height: defaultDrawerHeadHeight,),
                            Consumer<SaveDataProvider>(builder: (context,value,child){
                              return StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance.collection('Users').snapshots(),
                                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasError) {
                                    return Center(child: Text('Error: ${snapshot.error}'));
                                  }

                                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                    return Center(child: Text('No data found',style: TextStyle(color: Colors.black),));
                                  }

                                  List<DropdownMenuItem<String>> dropdownItems = snapshot.data!.docs.map((DocumentSnapshot document) {
                                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                                    return DropdownMenuItem<String>(
                                      value: data['category'],
                                      child: Text(data['category']),
                                    );
                                  }).toList();

                                  return DropdownButton<String>(
                                    value: selectedValue,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedValue = newValue;
                                      });
                                    },
                                    items: dropdownItems,
                                  );
                                },
                              );
                            }),
                            SizedBox(height: defaultDrawerHeadHeight,),
                            Container(
                              width: 400.0,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blueGrey),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none
                                  ),
                                  hintText: "Enter Routes",
                                ),
                              ),
                            ),
                            SizedBox(height: defaultDrawerHeadHeight,),
                            Consumer<MyImageProvider>(
                              builder: (context,value,child){
                                return ButtonWidget(text: "Pick Image", onClicked: (){value.pickImage(context);}, width: 100.0, height: 50.0);
                              },),
                          ],
                        ),
                        SizedBox(width: 100.0,),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Consumer<MyImageProvider>(
                                builder: (context, imageProvider, child) {
                                  return imageProvider.imageBytes != null
                                      ? Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                                    child: Container(
                                        height: 500.0,
                                        width: 300.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          image: imageProvider.imageBytes != null
                                              ? DecorationImage(
                                            image: MemoryImage(imageProvider.imageBytes!),
                                            fit: BoxFit.cover,
                                          )
                                              : null,
                                        )
                                    ),
                                  )
                                      : const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10.0),
                                    child: Text("No image selected."),
                                  );
                                }
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),

            // StreamBuilder(
            //   stream: firestore
            //       .collection("requests")
            //      // .where("code", isEqualTo: "1")
            //     //  .orderBy('timestamp', descending: true)
            //   .where("code", isEqualTo: "2")
            //       .snapshots(),
            //   builder: (context, snapshot) {
            //     return (snapshot.connectionState == ConnectionState.waiting)
            //         ? const Center(
            //       child: CircularProgressIndicator(
            //         color: hoverColor,
            //       ),
            //     )
            //         : snapshot.data!.docs.isEmpty
            //         ? Container(
            //       padding: const EdgeInsets.all(10.0),
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(10.0),
            //         color: Colors.white,
            //       ),
            //       child: Center(
            //         child: Text(
            //           "No Requests Found",
            //           style: TextStyle(
            //               fontSize: 18.0, fontWeight: FontWeight.bold),
            //         ),
            //       ),
            //     )
            //         : Container(
            //       width: double.infinity,
            //       decoration: BoxDecoration(
            //           borderRadius: BorderRadius.circular(10)),
            //       child: PaginatedDataTable(
            //           header: TextWidget(
            //             text:
            //             "Total Message Requests: ${snapshot.data!.docs.length}",
            //             size: 20,
            //             color: Colors.black,
            //             isBold: true,
            //           ),
            //           headingRowColor:
            //           MaterialStateProperty.resolveWith<Color>(
            //                 (Set<MaterialState> states) {
            //               length = snapshot.data!.docs.length;
            //               if (length! < snapshot.data!.docs.length) {
            //                 Get.snackbar("title", " message");
            //               }
            //               return primaryColor; // Default color
            //             },
            //           ),
            //           columnSpacing: 20.0,
            //           arrowHeadColor: Colors.black,
            //           rowsPerPage: snapshot.data!.docs.length > 10
            //               ? 10
            //               : snapshot.data!.docs.length,
            //           columns:  [
            //             DataColumn(
            //               label: TextWidget(
            //                 text: "Name",
            //                 color: Colors.black,
            //                 size: 14.0,
            //                 isBold: true,
            //               ),
            //             ),
            //             DataColumn(
            //               label: TextWidget(
            //                 text: "Phone Number",
            //                 color: Colors.black,
            //                 size: 14.0,
            //                 isBold: true,
            //               ),
            //             ),
            //             DataColumn(
            //               label: TextWidget(
            //                 text: "Pick Up",
            //                 color: Colors.black,
            //                 size: 14.0,
            //                 isBold: true,
            //               ),
            //             ),
            //             DataColumn(
            //               label: TextWidget(
            //                 text: "Drop Off",
            //                 color: Colors.black,
            //                 size: 14.0,
            //                 isBold: true,
            //               ),
            //             ),
            //             DataColumn(
            //               label: TextWidget(
            //                 text: "Book for now /later",
            //                 color: Colors.black,
            //                 size: 14.0,
            //                 isBold: true,
            //               ),
            //             ),
            //             DataColumn(
            //               label: TextWidget(
            //                 text: "Book Date / Time",
            //                 color: Colors.black,
            //                 size: 14.0,
            //                 isBold: true,
            //               ),
            //             ),
            //             DataColumn(
            //               label: TextWidget(
            //                 text: "Car Type",
            //                 color: Colors.black,
            //                 size: 14.0,
            //                 isBold: true,
            //               ),
            //             ),
            //             DataColumn(
            //               label: TextWidget(
            //                 text: "Driver Notes",
            //                 color: Colors.black,
            //                 size: 14.0,
            //                 isBold: true,
            //               ),
            //             ),
            //             DataColumn(
            //               label: TextWidget(
            //                 text: "Reply",
            //                 color: Colors.black,
            //                 size: 14.0,
            //                 isBold: true,
            //               ),
            //             ),
            //             DataColumn(
            //               label: TextWidget(
            //                 text: "Action",
            //                 color: Colors.black,
            //                 size: 14.0,
            //                 isBold: true,
            //               ),
            //             ),
            //           ],
            //           source: DataTableSourceImpl(
            //               category: snapshot.data!.docs,
            //               length: snapshot.data!.docs.length,
            //               context: context)),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  getPermissionNotification() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  pushNotificationMessageListner() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return NotificationDialogWidget(
                  title: message.notification!.title,
                  body: message.notification!.body);
            });
      }
    });
  }

  setToken(String? token) {
    print("\n\n FCM USER REGISTRATION TOKEN: " + token.toString());

    setState(() {
      _token = token;
    });
  }
}

class DataTableSourceImpl extends DataTableSource {
  final category;
  final length;
  final context;

  var comtroller = TextEditingController();
  var nameController = TextEditingController();
  var numController = TextEditingController();

  DataTableSourceImpl(
      {required this.category, required this.length, required this.context});

  @override
  DataRow? getRow(int index) {
    return DataRow.byIndex(
      index: index,
      color: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          return Colors.white; // Default color
        },
      ),
      cells: [
        DataCell(
          TextWidget(
            text: category[index][key_name].toString(),
            color: Colors.black,
            size: 14.0,
            isBold: false,
          ),
        ),
        DataCell(Row(
          children: [
            Container(
              width: 30,
              height: 30,
              margin: EdgeInsets.only(left: 2, top: 5, bottom: 10),
              decoration: BoxDecoration(
                  color: primaryColor, borderRadius: BorderRadius.circular(3)),
              child: const Center(child: Icon(Icons.phone)),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 10, right: 5.0, bottom: 5.0, top: 5.0),
              child: TextWidget(
                text: category[index][key_phone].toString(),
                color: Colors.black,
                size: 14.0,
                isBold: false,
              ),
            ),
          ],
        )),
        DataCell(
          TextWidget(
            text: category[index][key_pickup].toString(),
            color: Colors.black,
            size: 14.0,
            isBold: false,
          ),
        ),
        DataCell(
          TextWidget(
            text: category[index][key_dropOff].toString(),
            color: Colors.black,
            size: 14.0,
            isBold: false,
          ),
        ),
        DataCell(
          TextWidget(
            text: category[index][key_bookStatus].toString(),
            color: Colors.black,
            size: 14.0,
            isBold: false,
          ),
        ),
        DataCell(
          TextWidget(
            text:
            "${category[index]["bookDate"].toString()} -- ${category[index]["bookDate"].toString()}",
            color: Colors.black,
            size: 14.0,
            isBold: false,
          ),
        ),
        DataCell(
          TextWidget(
            text: category[index]["carType"].toString(),
            color: Colors.black,
            size: 14.0,
            isBold: false,
          ),
        ),
        DataCell(
          TextWidget(
            text: category[index][key_driverNote].toString(),
            color: Colors.black,
            size: 14.0,
            isBold: false,
          ),
        ),
        DataCell(
          TextWidget(
            text: category[index]["status"].toString(),
            color: Colors.black,
            size: 14.0,
            isBold: false,
          ),
        ),
        DataCell(Row(
          children: [
            InkWell(
                onTap: () {
                  Get.bottomSheet(Container(
                    width: Get.width,
                    height: Get.height / 2,
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        )),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: Get.width * 0.010),
                          Row(
                            children: [
                              TextWidget(
                                  text: "Customer Name: ",
                                  color: primaryColor,
                                  size: 18.0,
                                  isBold: true),
                              TextWidget(
                                  text: category[index][key_name].toString(),
                                  color: primaryColor,
                                  size: 14.0,
                                  isBold: false),
                            ],
                          ),
                          SizedBox(height: Get.width * 0.010),
                          CustomTextFormField(
                              hintText: "Customer reply",
                              controller: comtroller),
                          SizedBox(height: Get.width * 0.010),
                          CustomTextFormField(
                              hintText: "Driver Name",
                              controller: nameController),
                          SizedBox(height: Get.width * 0.010),
                          CustomTextFormField(
                              hintText: "Vehicle Number",
                              controller: numController),
                          SizedBox(height: Get.width * 0.010),
                          Consumer<ValueProvider>(
                            builder: (context, provider, child) {
                              return provider.isLoading == false
                                  ? ButtonWidget(
                                  text: "Send Reply",
                                  onClicked: () {
                                    provider.setLoading(true);
                                    var id =
                                    category[index]["id"].toString();
                                    firestore
                                        .collection("reply")
                                        .doc(id)
                                        .set({
                                      "message": comtroller.text.toString(),
                                      "name":
                                      nameController.text.toString(),
                                      "number":
                                      numController.text.toString(),
                                      "date": category[index]["date"]
                                          .toString(),
                                      "time": category[index]["time"]
                                          .toString(),
                                    }).whenComplete(() {
                                      firestore
                                          .collection("requests")
                                          .doc(id)
                                          .update({
                                        "status": "complete",
                                        "code": "3"
                                      }).whenComplete(() {
                                        Provider.of<ValueProvider>(context,
                                            listen: false)
                                            .setLoading(false);
                                        //  Get.snackbar("Message Deliver", "Message Send Successfully",backgroundColor: primaryColor,
                                        //  colorText: Colors.white);
                                        Get.back();
                                      });
                                    });
                                  },
                                  width: 200.0,
                                  height: 50.0)
                                  : ButtonLoadingWidget(
                                  width: 200.0, height: 50.0);
                            },
                          )
                        ],
                      ),
                    ),
                  ));
                },
                child: Icon(Icons.message)),
            SizedBox(
              width: 10.0,
            ),
            InkWell(
                onTap: () {
                  firestore.collection("requests")
                      .doc(category[index]["id"]).delete();
                },
                child: Icon(
                  Icons.delete,
                  color: Colors.red,
                )),
          ],
        )),
      ],
    );
  }

  @override
  int get rowCount => length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
