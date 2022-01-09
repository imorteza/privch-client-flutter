import 'package:flutter/material.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:xinlake_text/validator.dart';

import 'package:privch/models/shadowsocks.dart';

class ShadowsocksDetailPage extends StatefulWidget {
  const ShadowsocksDetailPage(this.shadowsocks, {Key? key}) : super(key: key);

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

      // indicate data has been changed
      Navigator.of(context).pop(true);
    }
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      onChanged: () => setState(() => (_isFormChanged = true)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // display name
          TextFormField(
            autovalidateMode: AutovalidateMode.always,
            textAlignVertical: TextAlignVertical.bottom,
            initialValue: widget.shadowsocks.name,
            decoration: const InputDecoration(labelText: "Display name"),
            validator: (value) {
              return (value != null && value.isNotEmpty) ? null : "Display name can't be empty";
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
                  textAlignVertical: TextAlignVertical.bottom,
                  decoration: const InputDecoration(labelText: "Host address"),
                  validator: (value) {
                    return (value != null && Validator.isURL(value))
                        ? null
                        : "Invalid host address";
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
                  textAlignVertical: TextAlignVertical.bottom,
                  decoration: const InputDecoration(labelText: "Host port"),
                  validator: (value) {
                    return (value != null && Validator.getPortNumber(value) != null)
                        ? null
                        : "Invalid port number";
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
            textAlignVertical: TextAlignVertical.bottom,
            decoration: InputDecoration(
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
              return (value != null && value.isNotEmpty) ? null : "Password can't be empty";
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
          "/home/shadowsocks/encrypt",
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
              color: Colors.white70,
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
