import 'package:flutter/material.dart';
import 'package:xinlake_text/validator.dart';

class ValidatorDemo extends StatefulWidget {
  const ValidatorDemo({Key? key}) : super(key: key);

  @override
  State<ValidatorDemo> createState() => _ValidatorState();
}

class _ValidatorState extends State<ValidatorDemo> {
  static const String _invalidInput = "Invalid input";
  static const InputDecoration _decoration = InputDecoration(
    contentPadding: EdgeInsets.only(top: 8, bottom: 4),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  decoration: _decoration.copyWith(label: const Text("Length 4 ~ 8")),
                  validator: (value) {
                    return (value != null && Validator.isLength(value, 4, 8))
                        ? null
                        : _invalidInput;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  decoration: _decoration.copyWith(label: const Text("Letters (a~z, A~Z)")),
                  validator: (value) {
                    return (value != null && Validator.isAlpha(value)) ? null : _invalidInput;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  decoration: _decoration.copyWith(label: const Text("Numbers")),
                  validator: (value) {
                    return (value != null && Validator.isNumeric(value)) ? null : _invalidInput;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  decoration: _decoration.copyWith(label: const Text("Letters, Numbers")),
                  validator: (value) {
                    return (value != null && Validator.isAlphanumeric(value))
                        ? null
                        : _invalidInput;
                  },
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  decoration: _decoration.copyWith(label: const Text("ASCII")),
                  validator: (value) {
                    return (value != null && Validator.isAscii(value)) ? null : _invalidInput;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  decoration: _decoration.copyWith(label: const Text("Multibyte")),
                  validator: (value) {
                    return (value != null && Validator.isMultibyte(value)) ? null : _invalidInput;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  decoration: _decoration.copyWith(label: const Text("Hexadecimal")),
                  validator: (value) {
                    return (value != null && Validator.isHexadecimal(value)) ? null : _invalidInput;
                  },
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  decoration: _decoration.copyWith(label: const Text("IP")),
                  validator: (value) {
                    return (value != null && Validator.isIP(value)) ? null : _invalidInput;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  decoration: _decoration.copyWith(label: const Text("Port number")),
                  validator: (value) {
                    return (value != null && Validator.getPortNumber(value) != null)
                        ? null
                        : _invalidInput;
                  },
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  decoration: _decoration.copyWith(label: const Text("FQDN")),
                  validator: (value) {
                    return (value != null && Validator.isFQDN(value)) ? null : _invalidInput;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  decoration: _decoration.copyWith(label: const Text("URL")),
                  validator: (value) {
                    return (value != null && Validator.isURL(value)) ? null : _invalidInput;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  decoration: _decoration.copyWith(label: const Text("Email")),
                  validator: (value) {
                    return (value != null && Validator.isEmail(value)) ? null : _invalidInput;
                  },
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  decoration: _decoration.copyWith(label: const Text("Base64")),
                  validator: (value) {
                    return (value != null && Validator.isBase64(value)) ? null : _invalidInput;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  decoration: _decoration.copyWith(label: const Text("UUID")),
                  validator: (value) {
                    return (value != null && Validator.isUUID(value)) ? null : _invalidInput;
                  },
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  decoration: _decoration.copyWith(label: const Text("Credit card")),
                  validator: (value) {
                    return (value != null && Validator.isCreditCard(value)) ? null : _invalidInput;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  decoration: _decoration.copyWith(label: const Text("ISBN")),
                  validator: (value) {
                    return (value != null && Validator.isISBN(value)) ? null : _invalidInput;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  decoration: _decoration.copyWith(label: const Text("Postal code")),
                  validator: (value) {
                    return (value != null && Validator.isPostalCode(value, "CN"))
                        ? null
                        : _invalidInput;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
