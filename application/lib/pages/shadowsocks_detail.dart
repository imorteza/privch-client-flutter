/*
  Xinlake Liu
  2022-04-10

  - The size of the qrcode image

  - When using the From autovalidateMode parameter, 
  its TextFormField does not trigger initial validation
 */

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:xinlake_text/validator.dart';

import '../models/shadowsocks/shadowsocks07.dart';
import '../pages/encrypt_list.dart';

class ShadowsocksDetailArguments {
  final bool isCreate;
  final Shadowsocks shadowsocks;

  ShadowsocksDetailArguments(this.isCreate, this.shadowsocks);
}

/// arguments: 0, Shadowsocks; 1, isCreate.
class ShadowsocksDetailPage extends StatefulWidget {
  static const route = "/home/shadowsocks";
  final ShadowsocksDetailArguments arguments;

  const ShadowsocksDetailPage(this.arguments, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShadowsocksDetailState();
}

class _ShadowsocksDetailState extends State<ShadowsocksDetailPage> {
  var _obscureText = true;

  Widget _buildForm() {
    const inputDecoration = InputDecoration(
      contentPadding: EdgeInsets.only(top: 8, bottom: 4),
    );

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // display name
          TextFormField(
            autovalidateMode: AutovalidateMode.always,
            initialValue: widget.arguments.shadowsocks.name,
            decoration: inputDecoration.copyWith(labelText: "Display name"),
            validator: (value) {
              if ((value != null && value.isNotEmpty)) {
                widget.arguments.shadowsocks.name = value;
                return null;
              }
              return "Display name can't be empty";
            },
          ),
          const SizedBox(height: 20),
          // server address and port
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  initialValue: widget.arguments.shadowsocks.address,
                  decoration: inputDecoration.copyWith(
                    labelText: "Host address",
                    enabled: widget.arguments.isCreate,
                  ),
                  validator: (value) {
                    if ((value != null && Validator.isURL(value))) {
                      widget.arguments.shadowsocks.address = value;
                      return null;
                    }
                    return "Invalid host address";
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  keyboardType: TextInputType.number,
                  initialValue: "${widget.arguments.shadowsocks.port}",
                  decoration: inputDecoration.copyWith(
                    labelText: "Host port",
                    enabled: widget.arguments.isCreate,
                  ),
                  validator: (value) {
                    if (value != null) {
                      final port = Validator.getPortNumber(value);
                      if (port != null) {
                        widget.arguments.shadowsocks.port = port;
                        return null;
                      }
                    }
                    return "Invalid port number";
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // server password
          TextFormField(
            autovalidateMode: AutovalidateMode.always,
            obscureText: _obscureText,
            initialValue: widget.arguments.shadowsocks.password,
            decoration: inputDecoration.copyWith(
              labelText: "Password",
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscureText = !_obscureText);
                },
              ),
            ),
            validator: (value) {
              if ((value != null && value.isNotEmpty)) {
                widget.arguments.shadowsocks.password = value;
                return null;
              }
              return "Password can't be empty";
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEncrypt() {
    return OutlinedButton(
      onPressed: () async {
        final encrypt = await Navigator.pushNamed(
          context,
          EncryptListPage.route,
          arguments: widget.arguments.shadowsocks.encrypt,
        ) as String?;
        if (encrypt != null && widget.arguments.shadowsocks.encrypt != encrypt) {
          setState(() {
            widget.arguments.shadowsocks.encrypt = encrypt;
          });
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Icon(Icons.enhanced_encryption),
          ),
          Expanded(
            child: Center(
              child: Text(widget.arguments.shadowsocks.encrypt.toUpperCase()),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(widget.arguments.shadowsocks.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // qr code
            Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: QrImage(
                padding: const EdgeInsets.all(20),
                data: widget.arguments.shadowsocks.encodeBase64(),
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 20),
            // server info
            _buildForm(),
            const SizedBox(height: 20),
            // server encrypt
            _buildEncrypt(),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
