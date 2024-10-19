import 'package:get/get.dart';


import '../Models/task.dart';
import '../db/db_helper.dart';

class TaskController extends GetxController {
  var taskList = <Task>[].obs;
  RxList<Task> filteredTaskList = <Task>[].obs;
  RxString searchQuery = ''.obs;
// 1 = High Priority (Red), 2 = Medium Priority (Yellow), 3 = Normal (No Color or Default)
  RxInt selectedSortPriority = 0.obs; // 0 = no sorting, 1 = high, 2 = medium, 3 = normal

  @override
  void onReady() {
    super.onReady();
    getTasks(); // Fetch tasks when the controller is ready
  }

  // Fetch tasks from the database
  void getTasks() async {
    List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => Task.fromJson(data)).toList());
    updateFilteredList(); // Update filtered list after fetching tasks
  }

  // Update filtered list based on search query and selected sort priority
  void updateFilteredList() {
    List<Task> tasksToFilter = List.from(taskList);

    if (searchQuery.isNotEmpty) {
      tasksToFilter = tasksToFilter.where((task) => isTaskMatching(task, searchQuery.value)).toList();
    }

    // Sort tasks based on the selected priority
    if (selectedSortPriority.value != 0) {
      tasksToFilter.sort((a, b) {
        if (selectedSortPriority.value == 1) { // High priority (red color)
          return b.color == 0 ? 1 : -1;
        } else if (selectedSortPriority.value == 2) { // Medium priority (yellow color)
          return b.color == 1 ? 1 : -1;
        } else { // Normal (no color or default)
          return b.color == 2 ? 1 : -1;
        }
      });
    }

    filteredTaskList.value = tasksToFilter;
  }

  // Set the sort priority and update the filtered list
  void setSortPriority(int priority) {
    selectedSortPriority.value = priority;
    updateFilteredList();
  }

  // Helper method to check if a task matches the search query
  bool isTaskMatching(Task task, String query) {
    return task.title!.toLowerCase().contains(query.toLowerCase()) ||
        (task.description != null && task.description!.toLowerCase().contains(query.toLowerCase()));
  }


  // Add task to the database and refresh task list
  Future<int> addTask(Task? task) async {
    int result = await DBHelper.insert(task);
    getTasks();
    return result;
  }

  // Delete a task
  void delete(Task task) {
    DBHelper.delete(task);
    getTasks();

  }

  // Mark a task as completed
  void markTaskCompleted(int id) async {
    await DBHelper.update(id);
    getTasks();
  }

  // Search tasks
  void searchTasks(String query) {
    searchQuery.value = query;
    updateFilteredList();
  }

  Future<void> updateTask(Task task) async {
    await DBHelper.updateTask(task);
    getTasks();
  }
}





// // Update filtered list based on search query
// void updateFilteredList() {
//   if (searchQuery.value.isEmpty) {
//     filteredTaskList.value = List.from(taskList);
//   } else {
//     List<Task> matchingTasks = [];
//     List<Task> nonMatchingTasks = [];
//
//     for (var task in taskList) {
//       if (isTaskMatching(task, searchQuery.value)) {
//         matchingTasks.add(task);
//       } else {
//         nonMatchingTasks.add(task);
//       }
//     }
//
//     // Sort matching tasks by relevance
//     matchingTasks.sort((a, b) {
//       bool aTitleMatch = a.title!.toLowerCase().contains(searchQuery.value.toLowerCase());
//       bool bTitleMatch = b.title!.toLowerCase().contains(searchQuery.value.toLowerCase());
//       if (aTitleMatch && !bTitleMatch) return -1;
//       if (!aTitleMatch && bTitleMatch) return 1;
//       return 0;
//     });
//
//     filteredTaskList.value = [...matchingTasks, ...nonMatchingTasks];
//   }
// }
//
// // Helper method to check if a task matches the search query
// bool isTaskMatching(Task task, String query) {
//   return task.title!.toLowerCase().contains(query.toLowerCase()) ||
//       (task.description != null && task.description!.toLowerCase().contains(query.toLowerCase()));
// }