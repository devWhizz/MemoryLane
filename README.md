# MemoryLane | Journaling iOS App

### MemoryLane is a unique journaling app crafted to give significance to your visual memories. In a world filled with countless images, each moment captured becomes a part of your personal narrative. The app focuses on the profound impact of your memories by seamlessly combining journaling and images, helping you create a rich tapestry of your experiences.

<br>
 
![](https://mediadesign.solutions/wp-content/uploads/2024/03/MemoryLane_homeview.png)
![](https://mediadesign.solutions/wp-content/uploads/2024/03/MemoryLane_timelineview.png)
![](https://mediadesign.solutions/wp-content/uploads/2024/03/MemoryLane_detailview1.png)
![](https://mediadesign.solutions/wp-content/uploads/2024/03/MemoryLane_detailview2.png)
![](https://mediadesign.solutions/wp-content/uploads/2024/03/MemoryLane_addmemoryview.png)

<br>

### Table of Contents
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Key Files](#key-files)
- [Key Features](#key-features)
- [Contributing](#contributing)

<br>

### Getting Started

To run the MemoryLane app on your local environment, follow these steps:

1. Clone the repository from [GitHub](https://github.com/devWhizz/MemoryLane).
2. Open the project in Xcode.
3. Build and run the app on an emulator or physical iOS device.

<br>

---

<br>

### Project Structure


The project follows a standard iOS app structure using the MVVM architecture. Here's an overview of the project structure:

<br>

![Static Badge](https://img.shields.io/badge/Group-Models-blue)

Contains the User and Memeory model, which define the structure and attributes of data entities in this application.

<br>

![Static Badge](https://img.shields.io/badge/Group-Managers-blue)

Includes the files managing access to Google Firestore and image pickers.

<br>

![Static Badge](https://img.shields.io/badge/Group-ViewModels-blue)

Provides all the necessary methods and functionality required for the application, coordinating the flow of data and user interactions.

<br>

![Static Badge](https://img.shields.io/badge/Group-Views-blue)

Includes Views for the app's user interface.

<br>

![Static Badge](https://img.shields.io/badge/Group-Components-blue)

Includes single views which are used as components on the main screens.

<br>

---

<br>

### Key Files

Here are some of the projects key files:

<br>

![Static Badge](https://img.shields.io/badge/Key_File-MemoryViewModel-blue)

This ViewModel manages data retrieval and manipulation for the application. It interacts with Google Firestore and Google Cloud Storage and provides data to the user interface. It handles operations such as adding, editing, loading and deleting memories.

<br>

![Static Badge](https://img.shields.io/badge/Key_File-UserViewModel-blue)

This ViewModel is responsible for checking the users authentication status and executing key operations, including adding, editing and loading user-related data.

<br>

![Static Badge](https://img.shields.io/badge/Key_File-LoginView-blue)

This view provides a user interface for logging into the MemoryLane app. Users enter their email and password, and upon valid input, they can log in. The view includes an option to navigate to the registration screen for new users.

<br>

![Static Badge](https://img.shields.io/badge/Key_File-HomeView-blue)

This view presents categorized memories with a localized interface. Users can easily add and search memories through toolbar buttons, triggering sheet views for a smooth interaction. The view dynamically fetches memories upon its appearance, ensuring an up-to-date and user-friendly experience.

<br>

![Static Badge](https://img.shields.io/badge/Key_File-TimelineView-blue)

This view presents categorized memories by month. Just like in the HomeView, users can add and search memories through toolbar buttons. Additionally, users can swipe to delete memories, invoking a confirmation alert for secure deletion.

<br>

![Static Badge](https://img.shields.io/badge/Key_File-AddMemoryView-blue)

This sheet is used for adding new memories to the application. Users can input details such as the category, memory title, description, date, location using the Google Places and Geocoding API and images that can be uploaded from the user's photo library. After inputting the required information, users can submit the memory details to add it to the app's database (Google Firestore).

<br>

![Static Badge](https://img.shields.io/badge/Key_File-EditMemoryView-blue)

This sheet is used for editing existing memories to the app. Users can change all details of previous saved memories. After updating the information, users can submit the changes to update the app's database.

<br>

![Static Badge](https://img.shields.io/badge/Key_File-FavoritesView-blue)

This view displays a list of preferred memories. Users can non-prefer memories through swipe actions and the view updates the list of preferred memories based on user interactions. It also provides a click action to navigate to the detail view for further information about that specific memory.

<br>

![Static Badge](https://img.shields.io/badge/Key_File-SearchView-blue)

This view allows the user to browse all of their stored memories by typing keywords into the search field. Search results appear in a list adapting to the input query.  

<br>

![Static Badge](https://img.shields.io/badge/Key_File-MemoryDetailView-blue)

This view displays detailed information about a specific memory. It is used to view memory details such as the title, descrioption, cover and gallery images, date and location displayed on Google Maps. The user has the opttion to share, edit, delete and favorize the memory on this view.

<br>

![Static Badge](https://img.shields.io/badge/Key_File-ProfileView-blue)

This view provides users with their profile and app settings. It includes options to toggle Dark Mode, and change the user profile picture and name.

<br>

---

<br>

### Key Features

<br>

![Static Badge](https://img.shields.io/badge/Key_Feature-Adding_a_Memory-blue)

Users can add a new memory to the application by following these steps:

1. Open the app and navigate to the "Add Memory" sheet by clicking the icon (+) in the app's toolbar.
2. Fill in the required information, such as the category, memory title, description, date, cover image, gallery images and location.
3. Submit the memory details to add it to the app's database (Google Firestore).

<br>

![Static Badge](https://img.shields.io/badge/Key_Feature-Favorites_Function-blue)

The favorizing feature allows users to mark their favorite memories. Here's how it works:

1. Browse through the list of memories.
2. When you find a memory that you'd like to favorize, navigate to its detail view and click the heart-shaped "Like" icon associated with that memory.
3. The memory will be added to your list of liked memories for easy access and reference.
4. You can always get to them by navigating to the FavoritesView from the tab bar (heart icon).

<br>

![Static Badge](https://img.shields.io/badge/Key_Feature-Search-blue)

The app includes a search feature that allows users to find specific memories by using keywords. Here's how you can use the search function:

1. Open the Search sheet by clicking the icon (magnifier) in the app's toolbar.
2. Enter a search query into the input field. Enter keywords related to the memory you're looking for.
3. As you type in your search query, the app dynamically filters the memories based on your input. The search results will display in real-time, updating as you type.
4. You can click on a memory from the search results to view more details about it.

<br>

![Static Badge](https://img.shields.io/badge/Key_Feature-Share-blue)

Users can share the memory details:

1. Click on a memory from the list to view its details.
2. Open the Share sheet by clicking the icon (share) in the app's toolbar.
3. Choose an application installed on your device to share all details of that memory.

<br>

---

<br>

### Contributing

Please report any issues or bugs through the [Issue Tracker](https://github.com/devWhizz/MemoryLane/issues).

<br>
<br>
