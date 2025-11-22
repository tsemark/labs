# Bug Reports

---

### Bug Report 1: Invalid Promo Code Error Message Not Displayed
**Bug ID**: JIRA-001  
**Component**: Checkout  
**Test Case ID**: CHK-MIN-01  
**Priority**: Medium  
**Severity**: Medium  
**Environment**: Firefox (latest), Staging environment, Mobile (iOS)  
**Reported Date**: January 01, 2025  
**Reported By**: QA Engineer  

**Summary**: Entering an invalid promo code does not display an error message, confusing users.  

**Description**: When an invalid promo code is entered during checkout, the system silently fails to apply the discount without informing the user, leading to a poor user experience. The form proceeds as if the code was valid, but no discount is applied.  

**Steps to Reproduce**:  
1. Add a product to the cart.  
2. Proceed to the checkout page.  
3. In the promo code field, enter an invalid code (e.g., "INVALID123").  
4. Click "Apply".  

**Expected Result**: Error message displayed: "Invalid code"; no discount applied; user prompted to correct or proceed.  
**Actual Result**: No error message shown; promo code field clears or remains unchanged; total price does not reflect any discount.  

**Attachments**:  
- Screenshot of checkout page post-promo code application.  
- Video showing no feedback after clicking "Apply".  

**Additional Information**:  
- Issue observed on Firefox mobile; needs testing on other browsers/devices.  
- Check client-side validation and server response for promo code handling.  
- User experience impact: Users may think the code was applied or abandon checkout due to confusion.  

---

### Bug Report 2: Navigating to other page Loses Cart Contents
**Bug ID**: JIRA-002 
**Component**: Checkout  
**Test Case ID**: CHK-MIN-XX
**Priority**: High  
**Severity**: High  
**Environment**: Safari (latest), Staging environment, Desktop  
**Reported Date**: [DATE]
**Reported By**: [QA]

**Summary**: Cart contents are lost after navigating to different page, even for logged-in users.  

**Description**: When a logged-in user's session times out after inactivity, the cart contents are not preserved upon re-login, contrary to the expected behavior. This leads to a frustrating experience, as users must re-add items to the cart.  

**Steps to Reproduce**:  
1. Log in with a valid user account.  
2. Add multiple items to the cart.  
3. Leave the session idle for >30 minutes to trigger timeout.  
4. Attempt to view cart or perform an action (e.g., checkout).  
5. Re-login when prompted.  
6. Check cart contents.  

**Expected Result**: User prompted to re-login; cart contents remain intact after re-login.  
**Actual Result**: Cart is empty after re-login; user must re-add items.  

**Attachments**:  
- Screenshot of cart before and after timeout.  
- Video of the process from login to cart loss.  

**Additional Information**:  
- Tested on Safari; needs cross-browser/device testing.  
- Check session storage mechanism (e.g., cookies, local storage) and cart persistence logic.  
- Business impact: Potential loss of sales due to user frustration.  

---

### Bug Report 3: Payment Form Accepts Invalid Card Number Without Validation
**Bug ID**: JIRA-003  
**Component**: Payment  
**Test Case ID**: PAY-MIN-XX  
**Priority**: High  
**Severity**: High  
**Environment**: Chrome (latest), Staging environment, Mobile (Android)  
**Reported Date**: [DATE]
**Reported By**: [QA]

**Summary**: Payment form submits with an invalid card number, causing a server error.  

**Description**: The payment form allows submission of an invalid credit card number (e.g., too few digits) without client-side validation, leading to a server-side error or timeout. This bypasses expected input validation and degrades user trust in the payment process.  

**Steps to Reproduce**:  
1. Proceed to checkout with items in the cart.  
2. Select "Credit Card" as the payment method.  
3. Enter an invalid card number (e.g., "1234" or "1111-1111-1111").  
4. Fill other fields with valid data (e.g., expiry, CVV).  
5. Click "Submit" to process payment.  

**Expected Result**: Form prevents submission with an error: "Invalid card number"; user prompted to correct input.  
**Actual Result**: Form submits; server returns an error (e.g., 500 Internal Server Error) or hangs, leaving user stuck.  

**Attachments**:  
- Screenshot of payment form with invalid input.  
- Screenshot of error page or timeout.  
- Network log showing server response (if available).  

**Additional Information**:  
- Tested on Chrome mobile; needs testing on other platforms.  
- Check client-side validation (e.g., Luhn algorithm) and server-side error handling.  
- Business impact: Failed payments may lead to abandoned checkouts.  

---

### Notes
- **Priority and Severity**:  
  - Critical/High for security (BR-001) and payment issues (BR-005) due to potential data breaches or revenue loss.  
  - Medium for usability issues (BR-002, BR-003, BR-004) impacting user experience but not critical functionality.  
- **Environment**: All bugs were tested in the staging environment; recommend retesting in production-like conditions.  
- **Next Steps**: Developers should prioritize BR-001 and BR-005 due to security and business impact. QA to retest fixes and perform regression testing on affected components.  
