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

class LoginViewController: UIViewController {
    
    // MARK: Properties
    var ref: Firebase!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Firebase(url: "https://chapeau-mgl.firebaseio.com/")
        
    }
    
    // Log in user by calling authAnonymouslyWithCompletionBlock() on database reference
    @IBAction func loginDidTouch(sender: AnyObject) {
        ref.authAnonymouslyWithCompletionBlock { (error, authData) in
            
            // Check for an authentication error; if none, send user to ChatViewController
            if error != nil {print(error.description); return }
            self.performSegueWithIdentifier("LoginToChat", sender: nil)
        }
        
    }
    
    // Set up destination view controller from segue, casting to UINavigationController, then to ChatViewController; then user gets local ID so JSQMessagesViewController can coordinate messages; user is anonymous because username is empty string
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        let navVC = segue.destinationViewController as! UINavigationController
        let chatVC = navVC.viewControllers.first as! ChatViewController
        chatVC.senderId = ref.authData.uid
        chatVC.senderDisplayName = ""
        
    }

    
}

