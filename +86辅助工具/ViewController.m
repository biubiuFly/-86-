//
//  ViewController.m
//  +86辅助工具
//
//  Created by 吴永康 on 2016/12/17.
//  Copyright © 2016年 吴永康. All rights reserved.
//

#import "ViewController.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import "GCD.h"
@interface ViewController ()<CNContactPickerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *add86Btn;
@property (weak, nonatomic) IBOutlet UIButton *sub86Btn;
@property (nonatomic, strong)CNContactPickerViewController *contact;
@property (weak, nonatomic) IBOutlet UIButton *shuomingBtn;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (nonatomic,strong)NSMutableArray *arr_contact;
@property (nonatomic,assign)NSUInteger count;
@end

@implementation ViewController

- (void)viewDidLoad {
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
    [super viewDidLoad];
    self.add86Btn.layer.cornerRadius = 25;
    self.sub86Btn.layer.cornerRadius = 25;
    self.shuomingBtn.layer.cornerRadius = 25;
    self.label1.text = @"";
    self.label2.text = @"使用前请先看说明";
    //判断授权状态
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
        CNContactStore *store = [[CNContactStore alloc]init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                NSLog(@"授权成功");
                
                //获取联系人仓库
                CNContactStore *store = [[CNContactStore alloc]init];
                
                //创建联系人信息的请求对象
                NSArray *keys = @[CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey];
                
                //根据请求key，创建请求对象
                CNContactFetchRequest *request = [[CNContactFetchRequest alloc]initWithKeysToFetch:keys];
                
                //发送请求
                [store enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
                    // 获取姓名
                    NSString * givenName = contact.givenName;
                    NSString * familyName = contact.familyName;
                    NSLog(@"%@-%@",givenName,familyName);
                    //获取电话
                    NSArray *phoneArray = contact.phoneNumbers;
                    for (CNLabeledValue *labelValue in phoneArray) {
                        CNPhoneNumber *number = labelValue.value;
                        NSLog(@"%@ -- %@",number.stringValue,labelValue.label);
                    }
                    
                    
                }];
                
                
            }else{
                NSLog(@"授权失败");
            }
        }];
    }
    self.arr_contact = [NSMutableArray array];
    //初始化一个联系人仓库
    CNContactStore *store = [[CNContactStore alloc]init];
    
    //创建联系人信息的请求对象
    NSArray *keys = @[CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey];
    
    //根据请求key，创建请求对象
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc]initWithKeysToFetch:keys];
    
    //发送请求
    [store enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        // 获取姓名
//        NSString * givenName = contact.givenName;
//        NSString * familyName = contact.familyName;
        [GCDQueue executeInGlobalQueue:^{
            [self.arr_contact addObject:contact];
        }];
    }];
}

- (IBAction)throughContacts:(UIButton *)sender {
    self.contact = [[CNContactPickerViewController alloc] init];
    // 设置代理
    self.contact.delegate = self;
    // 显示联系人窗口视图
    [self presentViewController:self.contact animated:YES completion:nil];
}

- (IBAction)add86:(UIButton *)sender {
    self.label1.text = @"正在运行+86程序，请稍后";
    self.count = 0;
    CNContactStore *store = [[CNContactStore alloc]init];
    
    //创建联系人信息的请求对象
    NSArray *keys = @[CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey];
    
    //根据请求key，创建请求对象
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc]initWithKeysToFetch:keys];
    
    //发送请求
    [store enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        // 获取姓名
        //        NSString * givenName = contact.givenName;
        //        NSString * familyName = contact.familyName;

        
        CNMutableContact *contact1 = [contact mutableCopy];
        NSArray *arr_phone = contact1.phoneNumbers;
        
        NSMutableArray *arr_fixPhone = [NSMutableArray array];
        for (CNLabeledValue *labelValue in arr_phone) {
            CNPhoneNumber *number = labelValue.value;
            NSString *phoneStr = number.stringValue;
            if (![phoneStr hasPrefix:@"+86"]) {
                phoneStr = [@"+86" stringByAppendingString:phoneStr];
                CNLabeledValue *va = [CNLabeledValue labeledValueWithLabel:labelValue.label value:[CNPhoneNumber phoneNumberWithStringValue:phoneStr]];
                [arr_fixPhone addObject:va];
                NSLog(@"phone - %@",phoneStr);
            }else{
                CNLabeledValue *va = [CNLabeledValue labeledValueWithLabel:labelValue.label value:[CNPhoneNumber phoneNumberWithStringValue:phoneStr]];
                [arr_fixPhone addObject:va];
            }
        }
        contact1.phoneNumbers = arr_fixPhone;
        
        CNSaveRequest *saveRequest = [[CNSaveRequest alloc]init];
        [saveRequest updateContact:contact1];
        [store executeSaveRequest:saveRequest error:nil];
        
        
        [GCDQueue executeInMainQueue:^{
        
        self.count++;

            self.label2.text = [NSString stringWithFormat:@"正在修改第%lu/%lu个联系人",(unsigned long)self.count,(unsigned long)self.arr_contact.count];
            
        }];
    }];
        self.label1.text = @"修改完成";
    [GCDQueue executeInMainQueue:^{
        self.label1.text = @" ";
        self.label2.text = @"使用前请先看说明";
    } afterDelaySecs:2];
}
- (IBAction)sub86:(UIButton *)sender {
    self.label1.text = @"正在运行-86程序，请稍后";
    self.count = 0;
    CNContactStore *store = [[CNContactStore alloc]init];
    
    //创建联系人信息的请求对象
    NSArray *keys = @[CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey];
    
    //根据请求key，创建请求对象
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc]initWithKeysToFetch:keys];
    
    //发送请求
    [store enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        // 获取姓名
        //        NSString * givenName = contact.givenName;
        //        NSString * familyName = contact.familyName;
        
        
        CNMutableContact *contact1 = [contact mutableCopy];
        NSArray *arr_phone = contact1.phoneNumbers;
        
        NSMutableArray *arr_fixPhone = [NSMutableArray array];
        for (CNLabeledValue *labelValue in arr_phone) {
            CNPhoneNumber *number = labelValue.value;
            NSString *phoneStr = number.stringValue;
            if ([phoneStr hasPrefix:@"+86"]) {
                NSRange rang = NSMakeRange(3, phoneStr.length-3);
                phoneStr = [phoneStr substringWithRange:rang];
                CNLabeledValue *va = [CNLabeledValue labeledValueWithLabel:labelValue.label value:[CNPhoneNumber phoneNumberWithStringValue:phoneStr]];
                [arr_fixPhone addObject:va];
                NSLog(@"phone - %@",phoneStr);
            }else{
                CNLabeledValue *va = [CNLabeledValue labeledValueWithLabel:labelValue.label value:[CNPhoneNumber phoneNumberWithStringValue:phoneStr]];
                [arr_fixPhone addObject:va];
            }
        }
        contact1.phoneNumbers = arr_fixPhone;
        
        CNSaveRequest *saveRequest = [[CNSaveRequest alloc]init];
        [saveRequest updateContact:contact1];
        [store executeSaveRequest:saveRequest error:nil];
        
        
        [GCDQueue executeInMainQueue:^{
            
            self.count++;
            
            self.label2.text = [NSString stringWithFormat:@"正在修改第%lu/%lu个联系人",(unsigned long)self.count,(unsigned long)self.arr_contact.count];
            
        }];
    }];
    self.label1.text = @"修改完成";
    
    [GCDQueue executeInMainQueue:^{
        self.label1.text = @" ";
        self.label2.text = @"使用前请先看说明";
    } afterDelaySecs:2];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
