import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/Models/task.dart';
import 'package:todo_list/controllers/task_controller.dart';
import 'package:todo_list/ui/theme.dart';
import 'package:todo_list/ui/widgets/button.dart';

import 'input_field.dart';

class AddTaskPage extends StatefulWidget {
  final Task? task;  // Add task parameter

  const AddTaskPage({Key? key, this.task}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}


class _AddTaskPageState extends State<AddTaskPage> {

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TaskController _taskController = Get.put(TaskController());

  DateTime _selectedDate = DateTime.now();
  String _endTime = "11:11 PM";
  String _startTime = DateFormat("hh:mm a").format(DateTime.now()).toString();
  int _selectedRemind = 5;
  List<int > remindList = [5,10,15,20];
  String _selectedRepeat = "";
  List<String> repeatList = ["None", "Daily", "Weekly", "Monthly"];
  int _selectedColor = 0;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      // Prepopulate fields if editing
      _titleController.text = widget.task!.title!;
      _descriptionController.text = widget.task!.description!;
      _selectedDate = DateFormat.yMd().parse(widget.task!.date!);
      _startTime = widget.task!.startTime!;
      _endTime = widget.task!.endTime!;
      _selectedRemind = widget.task!.remind!;
      _selectedRepeat = widget.task!.repeat!;
      _selectedColor = widget.task!.color!;
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Task',
                style: headingStyle,
              ),
              MyInputField(
                title: 'Title',
                hint: 'Enter your title',
                controller: _titleController,
              ),  MyInputField(
                title: 'Description',
                hint: 'Enter your description',
                controller: _descriptionController,
              ),

              MyInputField(
                title: 'Date',
                hint: DateFormat.yMd().format(_selectedDate),
                widget: IconButton(
                  icon:   Icon(Icons.calendar_month,color: Colors.grey,),
                  onPressed: (){
                    _getDateFromUser();
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: MyInputField(
                      title: 'Start Time',
                      hint: _startTime,
                      widget: IconButton(
                        icon:   Icon(CupertinoIcons.clock,color: Colors.grey,),
                        onPressed: (){
                          _getTimeFromUser(isStartTime: true);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: MyInputField(
                      title: 'End Time',
                      hint: _endTime,
                      widget: IconButton(
                        icon:   Icon(CupertinoIcons.clock,color: Colors.grey,),
                        onPressed: (){
                          _getTimeFromUser(isStartTime: false);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              MyInputField(title: 'Remind', hint: "$_selectedRemind minutes later",
         widget: DropdownButton<String>(
           icon: Icon(Icons.arrow_drop_down),iconSize: 32,elevation: 4,style: subTitleStyle,
           underline: Container(height: 0,),
           items: remindList.map<DropdownMenuItem<String>>((int value) {
             return DropdownMenuItem<String>(
               value: value.toString(),
               child: Text(value.toString()),
             );
           }).toList(),
           onChanged: (String? newValue) {
setState(() {
  _selectedRemind = int.parse(newValue!);
});
           },
         ),
              ),

              MyInputField(title: 'Repeat', hint: "$_selectedRepeat",
         widget: DropdownButton<String>(
           icon: Icon(Icons.arrow_drop_down),iconSize: 32,elevation: 4,style: subTitleStyle,
           underline: Container(height: 0,),
           items: repeatList.map<DropdownMenuItem<String>>((String value) {
             return DropdownMenuItem<String>(
               value: value,
               child: Text(value),
             );
           }).toList(),
           onChanged: (String? newValue) {
setState(() {
  _selectedRepeat = newValue!;
});
           },
         ),
              ),
              SizedBox(
  height: 18,
),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _colorPalette(),
                  MyButton(label: 'Create Task', onTap:()=> _validateData(),)
                ],
              )


            ],
          ),
        ),
      ),
    );
  }

_validateData(){
if(_titleController.text.isNotEmpty&& _descriptionController.text.isNotEmpty){
  _addTaskToDB();

  Get.back();

}
else if(_titleController.text.isEmpty || _descriptionController.text.isEmpty){
Get.snackbar('Data Missing', "All fields are supposed to be required !",
snackPosition: SnackPosition.BOTTOM,
backgroundColor:  Colors.white,
colorText: Colors.red,
icon: Icon(Icons.warning_amber_outlined,color: Colors.red,));

}
}


  _addTaskToDB() async {
    if (widget.task != null) {
      // Update existing task
      widget.task!.title = _titleController.text;
      widget.task!.description = _descriptionController.text;
      widget.task!.date = DateFormat.yMd().format(_selectedDate);
      widget.task!.startTime = _startTime;
      widget.task!.endTime = _endTime;
      widget.task!.remind = _selectedRemind;
      widget.task!.repeat = _selectedRepeat;
      widget.task!.color = _selectedColor;

      await _taskController.updateTask(widget.task!);  // Call update task method
    } else {
      // Add new task
      await _taskController.addTask(Task(
        description: _descriptionController.text,
        title: _titleController.text,
        date: DateFormat.yMd().format(_selectedDate),
        startTime: _startTime,
        endTime: _endTime,
        remind: _selectedRemind,
        repeat: _selectedRepeat,
        color: _selectedColor,
        isCompleted: 0,
      ));
    }
    Get.back();  // Go back after saving
  }




  _addTaskBar() {
    return ElevatedButton(
      onPressed: () async {
        await _addTaskToDB();  // Trigger task insertion
      },
      child: Text('Add Task'),
    );
  }

  _colorPalette(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color',style: titleStyle,),
        SizedBox(height: 8,),
        Wrap(
            children:
            List<Widget>.generate(
                3, (int index){
              return GestureDetector(
                onTap: (){
                  setState(() {
                    _selectedColor = index;
                  });},
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor:index==0 ? primaryClr : index ==1? reddd : yellow,
                    child: _selectedColor == index ? Icon(Icons.check,size: 16,color: Colors.white,): Container(),
                  ),
                ),
              );
            }
            )

        )
      ],
    );
  }
  _appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Icon(Icons.arrow_back_rounded, size: 23,color:
        Get.isDarkMode ? Theme.of(context).iconTheme.color : Theme.of(context).iconTheme.color,),
      ),
      actions: const [
        CircleAvatar(backgroundImage: AssetImage(
            "images/pfp.png"
        ),),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }

  _getDateFromUser() async {
    DateTime? _pickerDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2040),
    );
    if(_pickerDate!=null){
      setState(() {
        _selectedDate = _pickerDate;
      });

    }
    else{
      print('its null or smthn');
    }
  }

  _getTimeFromUser({required bool isStartTime}) async {
  var pickedTime = await _showTimePicker();
  String _formatedTime = pickedTime.format(context);
  if(pickedTime==null){
    print('time is null something');
  }else if(isStartTime == true){
    setState(() {
      _startTime = _formatedTime ;
    });

  }
  else if(isStartTime ==false){
    setState(() {
      _endTime = _formatedTime;

    });
  }
  }

  _showTimePicker() async {
  return showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
        initialTime: TimeOfDay(
            hour: int.parse(_startTime.split(":")[0],),
            minute: int.parse(_startTime.split(":")[1].split(" ")[0]),
        ));
  }

}
