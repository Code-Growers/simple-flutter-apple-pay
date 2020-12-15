import Flutter
import UIKit
import Foundation
import PassKit

typealias AuthorizationCompletion = (_ payment: String) -> Void
typealias AuthorizationViewControllerDidFinish = (_ error : NSDictionary) -> Void
typealias CompletionHandler = (PKPaymentAuthorizationResult) -> Void

public class SwiftFlutterApplePayPlugin: NSObject, FlutterPlugin, PKPaymentAuthorizationViewControllerDelegate {
    var authorizationCompletion : AuthorizationCompletion!
    var authorizationViewControllerDidFinish : AuthorizationViewControllerDidFinish!
    var pkrequest = PKPaymentRequest()
    var flutterResult: FlutterResult!;
    var completionHandler: CompletionHandler!
    var completionController: PKPaymentAuthorizationViewController!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "simple_flutter_apple_pay", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(SwiftFlutterApplePayPlugin(), channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "startPayment" {
            flutterResult = result;
            let parameters = NSMutableDictionary()
            var items = [PKPaymentSummaryItem]()
            let arguments = call.arguments as! NSDictionary
            
            guard let paymentNeworks = arguments["paymentNetworks"] as? [String] else {return}
            guard let countryCode = arguments["countryCode"] as? String else {return}
            guard let currencyCode = arguments["currencyCode"] as? String else {return}

            guard let paymentItems = arguments["paymentItems"] as? [NSDictionary] else {return}
            guard let merchantIdentifier = arguments["merchantIdentifier"] as? String else {return}
            
            for dictionary in paymentItems {
                guard let label = dictionary["label"] as? String else {return}
                guard let price = dictionary["amount"] as? Double else {return}
                guard let final = dictionary["isFinal"] as? Bool else {return}
                
                items.append(PKPaymentSummaryItem(label: label, amount: NSDecimalNumber(floatLiteral: price), type: final ? .final : .pending ))
            }
        
            
            parameters["paymentNetworks"] = paymentNeworks
            parameters["merchantIdentifier"] = merchantIdentifier
            parameters["countryCode"] = countryCode
            parameters["currencyCode"] = currencyCode
            
            parameters["paymentSummaryItems"] = items
            
            makePaymentRequest(parameters: parameters)
        }
        else if call.method == "closeWithSuccess" {
            closeApplePaySheetWithSuccess()
        }
        else if call.method == "closeWithError" {
            closeApplePaySheetWithError()
        }  else {
            result("Flutter method not implemented on iOS")
        }
    }
    
    func authorizationCompletion(_ payment: String) {
        flutterResult(payment)
    }
    
    func authorizationViewControllerDidFinish(_ error : NSDictionary) {
        //error
        flutterResult(error)
    }
    
    func makePaymentRequest(parameters: NSDictionary) {
        guard var paymentNetworks : [PKPaymentNetwork]               = parameters["paymentNetworks"]                 as? [PKPaymentNetwork] else {return}

        guard let merchantIdentifier            = parameters["merchantIdentifier"]              as? String else {return}
        guard let countryCode                   = parameters["countryCode"]                     as? String else {return}
        guard let currencyCode                  = parameters["currencyCode"]                    as? String else {return}
        
        guard let paymentSummaryItems           = parameters["paymentSummaryItems"]             as? [PKPaymentSummaryItem] else {return}
        
        
        if #available(iOS 12.0, *) {
            paymentNetworks = [.visa, .masterCard, .vPay]
        } else {
            paymentNetworks = [.visa, .masterCard]
        }
        // Cards that should be accepted
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
            
            pkrequest.merchantIdentifier = merchantIdentifier
            pkrequest.countryCode = countryCode
            pkrequest.currencyCode = currencyCode
            pkrequest.supportedNetworks = paymentNetworks
            // This is based on using Stripe
            pkrequest.merchantCapabilities = [.capabilityCredit, .capability3DS, .capabilityDebit]
            
            pkrequest.paymentSummaryItems = paymentSummaryItems
            
            let authorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: pkrequest)
            
            if let viewController = authorizationViewController {
                viewController.delegate = self
                guard let currentViewController = UIApplication.shared.keyWindow?.topMostViewController() else {
                    return
                }
                currentViewController.present(viewController, animated: true)
            }
        }
        return
    }

    public func closeApplePaySheetWithSuccess() {
        if (self.completionHandler != nil) {
            self.completionHandler(PKPaymentAuthorizationResult(status: .success, errors: nil))
        }
    }

    public func closeApplePaySheetWithError() {
        if (self.completionHandler != nil) {
            self.completionHandler(PKPaymentAuthorizationResult(status: .failure, errors: nil))
        }
    }
    
    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
            controller.dismiss(animated: true, completion: nil)
        }
    
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        self.completionHandler = completion
        self.completionController = controller
        flutterResult(["data": ["paymentData": payment.token.paymentData.base64EncodedString(), "transactionIdentifier": payment.token.transactionIdentifier]])
    }

}

extension UIWindow {
    func topMostViewController() -> UIViewController? {
        guard let rootViewController = self.rootViewController else {
            return nil
        }
        return topViewController(for: rootViewController)
    }
    
    func topViewController(for rootViewController: UIViewController?) -> UIViewController? {
        guard let rootViewController = rootViewController else {
            return nil
        }
        guard let presentedViewController = rootViewController.presentedViewController else {
            return rootViewController
        }
        switch presentedViewController {
        case is UINavigationController:
            let navigationController = presentedViewController as! UINavigationController
            return topViewController(for: navigationController.viewControllers.last)
        case is UITabBarController:
            let tabBarController = presentedViewController as! UITabBarController
            return topViewController(for: tabBarController.selectedViewController)
        default:
            return topViewController(for: presentedViewController)
        }
    }
}
