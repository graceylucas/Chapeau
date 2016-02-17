/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import Firebase
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController  {
    
    // Use built-in JSQMessage class to provide objects that conform to JSQMessageData protocol; use messages array to store instances of JSQMessage in app
    
    // MARK: Properties
    var messages = [JSQMessage]()
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    // Creates connection to Firebase database
    let rootRef = Firebase(url: "https://chapeau-mgl.firebaseio.com/")
    var messageRef: Firebase!
    
    // Creates reference tracking whether local user is typing
    var userIsTypingRef: Firebase!
    
    // Store whether the local user is typing in a private property
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
        
    }
    // Creates reference to the URL of /typingIndicator
    private func observeTyping() {
        let typingIndicatorRef = rootRef.childByAppendingPath("typingIndicator")
        userIsTypingRef = typingIndicatorRef.childByAppendingPath(senderId)
        // Delete indicator when user has left
        userIsTypingRef.onDisconnectRemoveValue()
    }
    
    
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
    
}


override func viewDidLoad() {
    super.viewDidLoad()
    title = "Chapeau"
    
    setUpBubbles()
    
    // Shrinks avatars to no size
    collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
    collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
    
    // used childByAppendingPath() helper method to create child reference
    messageRef = rootRef.childByAppendingPath("messages")
    
    observeMessages()
    
    observeTyping()
    
}

override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
}

override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
}

override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
    return messages[indexPath.item]
}

override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return messages.count
}

private func setUpBubbles() {
    let factory = JSQMessagesBubbleImageFactory()
    outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
    incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
}

// Override method sets color for message bubbles
override func collectionView(collectionView: JSQMessagesCollectionView!,
    messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        // Get message based on NSIndexPath item
        let message = messages[indexPath.item]
        
        // If message sent by the local user, eturn the outgoing imageview
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            // if message not sent by the local user, eturn the incoming imageview
            return incomingBubbleImageView
        }
}

// Remove avatar support
override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
    return nil
}

// Creates a new JSQMessage with a blank displayName and adds it to the data source
func addMessage(id: String, text: String) {
    let message = JSQMessage(senderId: id, displayName: "", text: text)
    messages.append(message)
}

override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
    let message = messages[indexPath.item]
    if message.senderId == senderId {
        cell.textView!.textColor = UIColor.whiteColor()
    } else  {
        cell.textView!.textColor = UIColor.blackColor()
    }
    return cell
}

// Send messages
override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
    
    // Create child reference with unique key using childByAutoId()
    let itemRef = messageRef.childByAutoId()
    
    //Create a dictionary to represent the message -- [String: AnyObject] works as a JSON-like object
    let messageItem = [
        "text": text,
        "senderId": senderId
    ]
    
    //Save the value at the new child location
    itemRef.setValue(messageItem)
    
    // Play sound
    JSQSystemSoundPlayer.jsq_playMessageSentSound()
    
    // Complete the “send” action and reset the input toolbar to empty
    finishSendingMessage()
    
    isTyping = false

}


// Synchronize data source

private func observeMessages() {
    // Create query that limits the synchronization to the last 25 messages
    let messagesQuery = messageRef.queryLimitedToLast(25)
    //Use the .ChildAdded to observe child items added/will be added at the messages location
    messagesQuery.observeEventType(.ChildAdded) { (snapshot: FDataSnapshot!) in
        // Extract the senderId and text from snapshot.value.
        let id = snapshot.value["senderId"] as! String
        let text = snapshot.value["text"] as! String
        
        // Call addMessage() to add the new message to the data source.
        self.addMessage(id, text: text)
        
        // Inform JSQMessagesViewController that a message has been received.
        self.finishReceivingMessage()
    }
    
    
}
}










