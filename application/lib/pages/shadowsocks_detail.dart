/*
  Xinlake Liu
  2022-02
 */

import 'package:flutter/material.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:xinlake_text/validator.dart';

import 'package:privch/models/shadowsocks.dart';
import 'package:privch/pages/encrypt_list.dart';

class ShadowsocksDetailPage extends StatefulWidget {
  const ShadowsocksDetailPage(this.shadowsocks, {Key? key}) : super(key: key);
  static const route = "/home/shadowsocks";

  // Fields in a Widget subclass are always marked "final".
  final Shadowsocks shadowsocks;

  @override
  _ShadowsocksEditState createState() => _ShadowsocksEditState();
}

class _ShadowsocksEditState extends State<ShadowsocksDetailPage> {
  final _formKey = GlobalKey<FormState>();

  bool _obscureText = true;
  bool _isFormChanged = false;
  bool _isEncryptChanged = false;

  void _check() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // indicate that data has been changed
      Navigator.pop(context, true);
    }
  }

  Widget _buildForm() {
    const inputDecoration = InputDecoration(
      contentPadding: EdgeInsets.only(top: 8, bottom: 4),
    );

    return Form(
      key: _formKey,
      onChanged: () => setState(() => (_isFormChanged = true)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // display name
          TextFormField(
            autovalidateMode: AutovalidateMode.always,
            initialValue: widget.shadowsocks.name,
            decoration: inputDecoration.copyWith(labelText: "Display name"),
            validator: (value) {
              if ((value != null && value.isNotEmpty)) {
                return null;
              }
              return "Display name can't be empty";
            },
            onSaved: (value) {
              if (value != null) {
                widget.shadowsocks.name = value;
              }
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
                  initialValue: widget.shadowsocks.address,
                  decoration: inputDecoration.copyWith(labelText: "Host address"),
                  validator: (value) {
                    if ((value != null && Validator.isURL(value))) {
                      return null;
                    }
                    return "Invalid host address";
                  },
                  onSaved: (value) {
                    if (value != null) {
                      widget.shadowsocks.address = value;
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  keyboardType: TextInputType.number,
                  initialValue: "${widget.shadowsocks.port}",
                  decoration: inputDecoration.copyWith(labelText: "Host port"),
                  validator: (value) {
                    if ((value != null && Validator.getPortNumber(value) != null)) {
                      return null;
                    }
                    return "Invalid port number";
                  },
                  onSaved: (value) {
                    if (value != null) {
                      widget.shadowsocks.port = int.parse(value);
                    }
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
            initialValue: widget.shadowsocks.password,
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
                return null;
              }
              return "Password can't be empty";
            },
            onSaved: (value) {
              if (value != null) {
                widget.shadowsocks.password = value;
              }
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
          arguments: widget.shadowsocks.encrypt,
        ) as String?;
        if (encrypt != null && widget.shadowsocks.encrypt != encrypt) {
          setState(() {
            widget.shadowsocks.encrypt = encrypt;
            _isEncryptChanged = true;
          });
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Icon(Icons.security),
          ),
          Expanded(
            child: Center(
              child: Text(widget.shadowsocks.encrypt.toUpperCase()),
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
        title: Text(widget.shadowsocks.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: ((_isFormChanged || _isEncryptChanged) && _formKey.currentState!.validate())
                ? _check
                : null,
          ),
        ],
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
                data: widget.shadowsocks.encodeBase64(),
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
}
