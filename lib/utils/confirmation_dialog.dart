import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final VoidCallback onTapYes;
  final VoidCallback onTapNo;

  const ConfirmationDialog({
    required this.onTapYes,
    required this.onTapNo,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 16.0, right: 16, top: 16, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.error_outline_outlined,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "Are you sure? Want to Logout ?",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onTapNo,
                  child: Text(
                    "No",
                    style: TextStyle(
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                TextButton(
                  onPressed: onTapYes,
                  child: const Text("Yes"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
