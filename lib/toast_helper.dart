

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BaseToastMessage{

  static ToastFailedMessage(){
    Fluttertoast.showToast(
        msg: "İşlem başarısız",
        toastLength: Toast.LENGTH_SHORT, // Toast mesajının süresi
        gravity: ToastGravity.BOTTOM, // Toast mesajının konumu (altta)
        backgroundColor: Colors.blue, // Toast arka plan rengi
        textColor: Colors.white, // Toast metin rengi
        fontSize: 20// Toast metin rengi

    );
  } static ToastSuccessMessage(){
    Fluttertoast.showToast(
        msg: "İşlem başarılı",
        toastLength: Toast.LENGTH_SHORT, // Toast mesajının süresi
        gravity: ToastGravity.BOTTOM, // Toast mesajının konumu (altta)
        backgroundColor: Colors.green, // Toast arka plan rengi
        textColor: Colors.white, // Toast metin rengi
        fontSize: 20// Toast metin rengi

    );
  }

  static ToastConnectionFailedMessage(){
    Fluttertoast.showToast(
        msg: "İşlem Başarısız.İnternet bağlantınızı kontol edin.",
        toastLength: Toast.LENGTH_SHORT, // Toast mesajının süresi
        gravity: ToastGravity.BOTTOM, // Toast mesajının konumu (altta)
        backgroundColor: Colors.blue, // Toast arka plan rengi
        textColor: Colors.white, // Toast metin rengi
        fontSize: 5// Toast metin rengi

    );
  }
  static ToastSameMessage(){
    Fluttertoast.showToast(
        msg: "Zaten Müsait.",
        toastLength: Toast.LENGTH_SHORT, // Toast mesajının süresi
        gravity: ToastGravity.BOTTOM, // Toast mesajının konumu (altta)
        backgroundColor: Colors.blue, // Toast arka plan rengi
        textColor: Colors.white, // Toast metin rengi
        fontSize: 5// Toast metin rengi

    );
  }


}
