import 'package:flutter/material.dart';

import 'init_viewmodel.dart';

class InitView extends StatelessWidget {
  InitView({super.key});

  final PinInputController controller = PinInputController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // 입력된 번호 표시 영역 (화면 1/3)

            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '비밀번호를 입력해주세요',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  ValueListenableBuilder(
                    valueListenable: controller.pin,
                    builder: (context, value, child) {
                      return Text(
                        '*' * controller.pin.value.length,
                        style: TextStyle(fontSize: 36, letterSpacing: 8),
                      );
                    },
                  ),
                ],
              ),
            ),


            // 키패드 영역 (화면 2/3)
            Expanded(
              flex: 1,
              child: GridView.builder(
                padding: EdgeInsets.all(20),
                reverse: true, // 아래에서부터 시작 (필수)
                itemCount: 12,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  // 숫자 키패드 올바르게 배치
                  List<String> keys = [
                    '',  '0', '⌫',
                    '7', '8', '9',
                    '4', '5', '6',
                    '1', '2', '3',
                  ];

                  String key = keys[index];

                  if (key.isEmpty) return SizedBox(); // 빈 자리 (레이아웃 맞춤)
                  if (key == '⌫') return _buildDeleteButton();
                  return _buildButton(context,key);
                },
              ),
            ),

            const SizedBox(height: 50,)
          ],
        ),
      ),
    );
  }


  Widget _buildButton(BuildContext context,String number) {
    return GestureDetector(
      onTap: () => controller.addNumber(context, number),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          shape: BoxShape.circle,
        ),
        child: Text(
          number,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: () => controller.deleteNumber(),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.backspace, size: 24),
      ),
    );
  }
}