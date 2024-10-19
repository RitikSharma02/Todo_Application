import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todo_list/controllers/task_controller.dart';
import 'package:todo_list/services/Notification_services.dart';
import 'package:todo_list/services/theme_services.dart';
import 'package:todo_list/ui/theme.dart';
import 'package:todo_list/ui/widgets/add_task_bar.dart';
import 'package:todo_list/ui/widgets/button.dart';
import 'package:todo_list/ui/widgets/input_field.dart';
import 'package:todo_list/ui/widgets/task_tile.dart';

import '../Models/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  late NotifyHelper notifyHelper;
  final TaskController _taskController = Get.put(TaskController());
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    notifyHelper = NotifyHelper();
    _initializeNotifications();

  }


  Future<void> _initializeNotifications() async {
    await notifyHelper.initializeNotification();

    await _requestNotificationPermission();
    await _requestExactAlarmPermission();

  }

  Future<void> _requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (status.isDenied) {
      status = await Permission.notification.request();
    }
    print("Notification permission status: ${status.isGranted ? 'granted' : 'denied'}");
  }

  Future<void> _requestExactAlarmPermission() async {
    // Check the current status of the permission
    var status = await Permission.scheduleExactAlarm.status;

    // Request permission
    if (status.isDenied) {
      status = await Permission.scheduleExactAlarm.request();
    }

    //permission status
    print("Exact alarm permission status: ${status.isGranted ? 'granted' : 'denied'}");
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        _searchFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: _appBar(),
        body: Column(
          children: [
        _searchAndSortBar(context),
        _addTaskBar(),
        _addDateBar(),
        const SizedBox(
          height: 10,
        ),
        _showTasks(),

          ],
        ),
      ),
    );
  }

  _searchAndSortBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Search Bar
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 20),
            height: 40,
            decoration: BoxDecoration(
              color: Get.isDarkMode ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (value) => _taskController.searchTasks(value),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: subTitleStyle,
                contentPadding: const EdgeInsets.only(left: 15, bottom: 7),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.surface,
                    width: 0,
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.surface,
                    width: 0,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Sorting Icon with Priority Options
        PopupMenuButton<int>(
          icon: Icon(
            Icons.sort,
            color: Get.isDarkMode ? Colors.white : Colors.black,
          ),
          onSelected: (priority) {
            _taskController.setSortPriority(priority);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 0, child: Text("Normal")),
            const PopupMenuItem(value: 2, child: Text("High Priority")),
            const PopupMenuItem(value: 3, child: Text("Medium Priority")),
            // const PopupMenuItem(value: 1, child: Text("latest first")),
          ],
        ),
      ],
    );
  }


  _showTasks() {
    return Expanded(
      child: Obx(() {
        if (_taskController.filteredTaskList.isEmpty) {
          return Center(child: Text("No tasks found"));
        } else {
          return ListView.builder(
            itemCount: _taskController.filteredTaskList.length,
            itemBuilder: (context, index) {
              Task task = _taskController.filteredTaskList[index];
              bool isMatchingTask = _taskController.searchQuery.isNotEmpty &&
                  _taskController.isTaskMatching(task, _taskController.searchQuery.value);

              if (task.repeat == 'Daily' ||
                  task.date == DateFormat.yMd().format(_selectedDate) ||
                  isMatchingTask) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  child: SlideAnimation(
                    child: FadeInAnimation(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showBottomSheet(context, task);
                            },
                            child: TaskTile(task, isHighlighted: isMatchingTask),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
          );
        }
      }),
    );
  }

  _showBottomSheet(BuildContext context, Task task){
Get.bottomSheet(
  Container(
    padding: EdgeInsets.only(top:4),
    height: task.isCompleted ==1?
    MediaQuery.of(context).size.height*0.28:MediaQuery.of(context).size.height*0.36,
    color: Get.isDarkMode?darkgrey:Colors.white,
    child: Column(
      children: [
        Center(
          child: Container(
            height: 5,
            width:  120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Get.isDarkMode?Colors.grey[600]:Colors.grey[300]
            ),
          ),
        ),
Spacer(),
        task.isCompleted==1? Container() :
        _bottomSheetButton(label: "Task Completed",
            onTap: (){
          _taskController.markTaskCompleted(task.id!);

          Get.back();
            }, clr: primaryClr,
        context: context),

        task.isCompleted==1? Container(): _bottomSheetButton(label: "Edit Task",
            onTap: () {
              Get.to(() => AddTaskPage( task : task));  // Pass the task to AddTaskPage
            },

            clr: Colors.green[300]!,
            context: context),

        _bottomSheetButton(label: "Delete Task",
onTap: (){
  _taskController.delete(task);
},


             clr: Colors.red[300]!,
            context: context),

        SizedBox(
          height: 20,
        ),
        _bottomSheetButton(label: "Close",
            onTap: (){
              Get.back();
            }, clr: Colors.red[300]!,
            isClose: true,
            context: context),
        SizedBox(
          height: 10,
        ),
      ],
    ),
  ),
);
  }

  _bottomSheetButton({
    required String label,
    required Function() onTap,
    required Color clr,
    bool isClose =false,
  required BuildContext context
  })
  {
 return GestureDetector(
  onTap: onTap,
  child: Container(
    margin: EdgeInsets.symmetric(vertical: 4),
    height: 50,
    width: MediaQuery.of(context).size.width*0.9,

decoration: BoxDecoration(
  border: Border.all(
    width: 2,
    color: isClose==true?Get.isDarkMode?Colors.grey[600]!:Colors.grey[300]!:clr,
  ),
  borderRadius: BorderRadius.circular(20),
  color: isClose==true?Colors.transparent:clr,
),
    child: Center(
      child: Text(
        label,style: isClose?titleStyle: titleStyle.copyWith(color: Colors.white),
      ),
    ),
  ),
);
  }
  _addDateBar(){
    return  Container(
        margin: EdgeInsets.only(left: 20, top: 10),
        child: DatePicker(
          DateTime.now(),
          height: 100,
          width: 80,
          initialSelectedDate: DateTime.now(),
          selectionColor: primaryClr,
          selectedTextColor: Colors.white,
          dateTextStyle: GoogleFonts.lato(
            textStyle:  TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey
            ),),
          dayTextStyle: GoogleFonts.lato(
            textStyle:  TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey
            ),),
          monthTextStyle: GoogleFonts.lato(
            textStyle:  TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey
            ),),

          onDateChange: (date){
            setState(() {
              _selectedDate = date;

            });
          },

        )
    );
  }
  _addTaskBar(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text( DateFormat.yMMMd().format( DateTime.now()),style: subHeadingStyle,),
              Text('Today',style: headingStyle,),
            ],
          ),
          MyButton(label: '+ Add task', onTap: () async{

       await Get.to(AddTaskPage());
       _taskController.getTasks();
          }

    )


        ],
      ),
    );
  }


  AppBar _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: GestureDetector(
        onTap: () {
          ThemeService().SwitchTheme();

          notifyHelper.displayNotification(
            title: 'Theme Changed',
            body: Get.isDarkMode ? "Light theme Activated" : "Dark theme Activated",
          );


         // notifyHelper.scheduledNotification(title: 'scheduled hun beta', body: 'hahahha working');
         //
         // notifyHelper.zonedScheduleAlarmClockNotification(title: 'zone scheduled hun beta', body: 'hahahha working');

        },
        child: Icon(Get.isDarkMode? Icons.sunny: Icons.nightlight_round, size: 20,color:

          Get.isDarkMode ? Theme.of(context).iconTheme.color : Theme.of(context).iconTheme.color,),
      ),
      actions:    [
     CircleAvatar(backgroundImage: AssetImage(
           "images/pfp.png"
           ),),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }
}

