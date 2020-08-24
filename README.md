# Otter
Otter is a real-time social media app utilizing Google Firestore and Google Firebase.

## Features
* Login
* Sign up 
* Add a post
* Like or share another user's post
* View posts from users you follow
* View posts from all Otter users
* View profiles of other users
  * follow/unfollow users
  * view their posts, shared posts, and favorited posts
* Search for users by name or username
* Message users you follow
  * Send texts or photos
  * Save photos from chat
* Edit user profile
* Update password or email
* Delete account


### Login 
  * User authentication with Firebase
  * Forgot password
    * Reset password with Firebase
  * Sign in persistance
  
  <img src="Images/welcome.png" width="270"/> <img src="Images/login.png" width="270"/> <img src="Images/forgotpassword.png" width="270"/> 
  
### Sign Up
  * Email validation
  * Username validation
    * Usernames must be unique
  * Strong password validation
    * Valid passwords have at least length 8, 1 letter, and 1 special character
    
  <img src="Images/welcome.png" width="270"/> <img src="Images/register.png" width="270"/>
 
### Home
  * Posts from users the logged in user follows
  * New post alert if the user is scrolled down and a post was added
  
  <img src="Images/homeposts.png" width="270"/> <img src="Images/newpost.png" width="270"/>
 
### Posts
  * Can be shared or favorited
  * Have time/date stamps
  * Profile image can be tapped to be taken to the poster's profile page
  * Post length imited to 150 characters
  
  <img src="Images/addpost.png" width="270"/> <img src="Images/addposttext.png" width="270"/> <img src="Images/addpostmoretext.png" width="270"/>
  
### Menu

<img src="Images/menu.png" width="270"/> 

  * User profile
    * Edit profile
      * Change profile photo
      * Change header photo
      * Update name
      * Update username
      * Update bio
   
  <img src="Images/userprofileposts.png" width="270"/> <img src="Images/userprofilefavorited.png" width="270"/> <img src="Images/editprofile.png" width="270"/>
       
  * Settings
    * Update password
    * Update email
    * Delete account
    
  <img src="Images/settings.png" width="270"/> <img src="Images/updatepassword.png" width="270"/> <img src="Images/updateemail.png" width="270"/> <img src="Images/deleteaccount.png" width="270"/>
  
### Otter Global
  * Posts from all Otter users
  <img src="Images/otterglobal.png" width="270"/> 
  
### Other User
  * Can follow or unfollow other users
  * Can view posts, shared posts, and favorited posts of other users
  
  <img src="Images/otheruser.png" width="270"/>
   
### Search 
  * Search for other Otter users by name or username
  
  <img src="Images/searchuser.png" width="270"/> <img src="Images/searcheduser.png" width="270"/> 
  
### Messages
  * Add chat
    * Message followed users
    
  <img src="Images/addmessage.png" width="270"/>
  
  * Chat
    * Send text messages or images
    * Save images
      * Click the save image icon
      * Hold on the image until the popup appears
    * Click the info icon to see the profile of the user you are chatting with
  
  <img src="Images/messages.png" width="270"/> <img src="Images/chat2.png" width="270"/> <img src="Images/chatimage.png" width="270"/>  
  <img src="Images/messages.png" width="270"/> <img src="Images/chat1.png" width="270"/> <img src="Images/holdsaveimage.png" width="270"/> 
  

