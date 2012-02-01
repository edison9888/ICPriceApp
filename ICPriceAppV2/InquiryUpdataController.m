//
//  InquiryUpdataController.m
//  IcpriceDemo
//
//  Created by Fei Gao on 11-2-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InquiryUpdataController.h"
#import "InquiryUpdataDataSource.h"
#import "Inquiry.h"
#import "Contact.h"
#import "IBAButtonFormField.h"
#import "IBAFormSection.h"
#import "IBAPickListFormField.h"
#import "IBAFormSection.h"
#import "User.h"
#import "IBAInputManager.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "NSStringAdditions.h"
@implementation InquiryUpdataController

@synthesize type = _type;
@synthesize contact;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [_type release];
    _type = nil;
	[contact release];
    contact = nil;
	
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = @"询价更新";
		NSMutableDictionary *formModel = [[[NSMutableDictionary alloc] init] autorelease];
		InquiryUpdataDataSource *formDataSourcet = [[InquiryUpdataDataSource alloc] initWithModel:formModel] ;
		self.formDataSource = formDataSourcet;
		[formDataSourcet release];

		[self.formDataSource setModelValue:((Inquiry*)[kAppDelegate.temporaryValues 
                                                       objectForKey:@"inquiry"]).quantity
								forKeyPath:@"quantity"];
	
		[self.formDataSource setModelValue:((Inquiry*)[kAppDelegate.temporaryValues 
                                                       objectForKey:@"inquiry"]).batch
								forKeyPath:@"batch"];
		
		[self.formDataSource setModelValue:[NSArray arrayWithObject:((Inquiry*)[kAppDelegate.temporaryValues 
                                                                                objectForKey:@"inquiry"]).batch]
													forKeyPath:@"status"];
//        NSLog(@"supplier %@",((Inquiry*)[kAppDelegate.temporaryValues 
//                                         objectForKey:@"inquiry"]).supplier);
        
		if (![((Inquiry*)[kAppDelegate.temporaryValues 
                         objectForKey:@"inquiry"]).supplier isEmptyOrWhitespace]) {
			//获取联系人
			[self getContact];
		}else{
			IBAButtonFormField * supplier = [[IBAButtonFormField alloc] initWithTitle:@"供货商"
																				 icon:nil
																	   executionBlock:^{
																		   [((Inquiry*)[kAppDelegate.temporaryValues 
                                                                                        objectForKey:@"inquiry"]) addObserver:self forKeyPath:@"supplierName" 
																										options:(NSKeyValueObservingOptionNew|
																												 NSKeyValueObservingOptionOld) 
																										context:nil];
																		   [((Inquiry*)[kAppDelegate.temporaryValues 
                                                                                        objectForKey:@"inquiry"]) addObserver:self forKeyPath:@"ider" 
																										options:(NSKeyValueObservingOptionNew|
																												 NSKeyValueObservingOptionOld) 
																										context:nil];
																		   
                                                                           [self presentModalViewController:[kAppDelegate loadFromVC:@"SupplierSearchViewController"]
                                                                                                   animated:YES];
                                                                           
																		   
																		   
																	   }];
			[(IBAFormSection*)[self.formDataSource.sections objectAtIndex:0] 
			 addFormField:[supplier autorelease]];
			[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
						  withRowAnimation:UITableViewRowAnimationNone];
		}
	}
	return self;
}


-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	if (isPhone) {
		return NO;
	}else {
		return YES;
	}
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
						change:(NSDictionary *)change context:(void *)context {	
	if ([keyPath isEqualToString:@"supplierName"]) {
		[self getContact];
	}
	
	[((Inquiry*)[kAppDelegate.temporaryValues 
                 objectForKey:@"inquiry"]) removeObserver:self forKeyPath:@"supplierName"];
	[((Inquiry*)[kAppDelegate.temporaryValues 
                 objectForKey:@"inquiry"]) removeObserver:self forKeyPath:@"ider"];
}

-(void)getContact{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kRESTBaseUrl]];
    NSMutableDictionary *operationData = [NSMutableDictionary dictionary];

    [operationData setValue:@"up_iphone_getWays" forKey:@"ObjectName"];
    [operationData setValue:[NSArray arrayWithObject:((Inquiry*)[kAppDelegate.temporaryValues 
                                                                 objectForKey:@"inquiry"]).supplier] 
                     forKey:@"Values"];
    
    [request setPostValue:@"PRC" forKey:@"OperationCode"];
    [request setPostValue:[operationData JSONString] forKey:@"OperationData"];

	[request setRequestMethod:@"POST"];
    [request setDelegate:self];
    request.didFinishSelector = @selector(requestDidFinishLoad:);
    request.didFailSelector = @selector(finishFail:);
	[request startAsynchronous];

}

-(void)finishFail:(ASIHTTPRequest *)request{
	[kAppDelegate HUDHide];
	[kAppDelegate alert:@"" message:[[request error] localizedDescription]];
}

-(void)requestDidFinishLoad:(ASIHTTPRequest *)request{
    NSDictionary *data =[[JSONDecoder decoder] objectWithData:[request responseData]];
	
	IBAFormSection *section = (IBAFormSection*)[self.formDataSource.sections objectAtIndex:0];
	[section.formFields removeAllObjects];
	IBAButtonFormField * supplier = [[IBAButtonFormField alloc] initWithTitle:((Inquiry*)[kAppDelegate.temporaryValues 
                                                                                          objectForKey:@"inquiry"]).supplierName
																		 icon:nil
															   executionBlock:^{
																   
																   [((Inquiry*)[kAppDelegate.temporaryValues 
                                                                                objectForKey:@"inquiry"]) addObserver:self forKeyPath:@"supplierName" 
																								options:(NSKeyValueObservingOptionNew|
																										 NSKeyValueObservingOptionOld) 
																								context:nil];
																   [((Inquiry*)[kAppDelegate.temporaryValues 
                                                                                objectForKey:@"inquiry"]) addObserver:self forKeyPath:@"ider" 
																								options:(NSKeyValueObservingOptionNew|
																										 NSKeyValueObservingOptionOld) 
																								context:nil];
																   
                                                                   [self presentModalViewController:[kAppDelegate loadFromVC:@"SupplierSearchViewController"]
                                                                                           animated:YES];
																   
																   
															   }];
	[section addFormField:[supplier autorelease]];
    

    
    IBAButtonFormField * contactButton = [[IBAButtonFormField alloc] initWithTitle:@"商家联系人"
                                                                              icon:nil
                                                                    executionBlock:^{
                                                                        UIActionSheet *actionSheet = nil;
                                                                        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                                                                  delegate:self 
                                                                                                         cancelButtonTitle:@"取消"
                                                                                                    destructiveButtonTitle:nil
                                                                                                         otherButtonTitles:nil,nil];
                                                                        
                                                                        for (NSArray *cont  in [data objectForKey:@"OutputTable"]) {
                                                                            NSString *_tit = [NSString stringWithFormat:@"%@ %@ %@ %@",
                                                                             [cont objectAtIndex:4],
                                                                             [cont objectAtIndex:2],
                                                                             [(NSString*)[cont objectAtIndex:3] 
                                                                              isEqualToString:@"m"]?
                                                                                              @"男":@"女",[cont objectAtIndex:6]];
                                                                             [actionSheet addButtonWithTitle:_tit];

                                                                        }
                                                                        
                                                                        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
                                                                        [actionSheet showInView:self.tableView];
                                                                        [actionSheet release];
                                                                    }];
    [section addFormField:contactButton];
    [contactButton release];
	
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
				  withRowAnimation:UITableViewRowAnimationNone];
	
}



-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (![[actionSheet buttonTitleAtIndex:buttonIndex]
		 isEqualToString:@"取消"]) {
		
		if (![[UIDevice currentDevice].model isEqualToString:@"iPhone"]) {
			[kAppDelegate alert:@"" message:@"必须是iPhone才能拨出号码"];
		}else {
			phone = [[[actionSheet buttonTitleAtIndex:buttonIndex] componentsSeparatedByString:@" "] lastObject];
            
			UIAlertView *sAlert = [[UIAlertView alloc] initWithTitle:@"是否拨出"
															 message:phone
															delegate:self
												   cancelButtonTitle:@"取消"
												   otherButtonTitles:nil];
			[sAlert addButtonWithTitle:@"拨出"];
			[sAlert show];
			[sAlert release];
			sAlert = nil;
		}
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 1) {
		 NSString *urlPhoneNumber = [NSString stringWithFormat:@"tel://%@",
									 phone];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPhoneNumber]]; 
	}
}


-(void)inquiryUpdata{
    
	[[IBAInputManager sharedIBAInputManager] deactivateActiveInputRequestor];
    NSString *tStatus;
	NSString *temp;
	if ([[self.formDataSource.model objectForKey:@"status"] isKindOfClass:[NSArray class]]) {
		temp = [((NSArray*)[self.formDataSource.model objectForKey:@"status"]) objectAtIndex:0];
	}else {
		temp = [((NSSet*)[self.formDataSource.model objectForKey:@"status"]) anyObject];
	}
    tStatus = [((NSMutableDictionary*)[kAppDelegate.constants objectAtIndex:2]) valueForKey:temp];
    
    [kAppDelegate HUDShow:@"提交中" yOffset:@"0"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kRESTBaseUrl]];
    NSMutableDictionary *operationData = [NSMutableDictionary dictionary];
    
    [operationData setValue:@"up_iphone_update_caigourfq" forKey:@"ObjectName"];
//    @uID int,
//    @cusInqId int,
//    @ID int,
//    @数量int,
//    @suPrice smallmoney, 价格
//    @批号varchar(20),
//    @芯片状态ID tinyint,
//    @suPtID int, 快查页面带过来
//    @cuNote varchar(100) 备注
    [operationData setValue:[NSArray arrayWithObjects:
                             kAppDelegate.user.ider,
                             ((Inquiry*)[kAppDelegate.temporaryValues objectForKey:@"inquiry"]).cusInqID,
                             ((Inquiry*)[kAppDelegate.temporaryValues objectForKey:@"inquiry"]).ider,
                             [self.formDataSource.model objectForKey:@"quantity"],
                             [self.formDataSource.model objectForKey:@"price"],
                             [self.formDataSource.model objectForKey:@"batch"],
                             tStatus,
                             ((Inquiry*)[kAppDelegate.temporaryValues objectForKey:@"inquiry"]).platform,
                             [self.formDataSource.model objectForKey:@"remarks"],
                             nil] 
                     forKey:@"Values"];
    
    [request setPostValue:@"PRC" forKey:@"OperationCode"];
    [request setPostValue:[operationData JSONString] forKey:@"OperationData"];
    
	[request setRequestMethod:@"POST"];
    [request setDelegate:self];
    request.didFinishSelector = @selector(inquiryUpdataHandler:);
    request.didFailSelector = @selector(finishFail:);
	[request startAsynchronous];
}

-(void)inquiryUpdataHandler:(ASIHTTPRequest *)request{
    NSDictionary *data =[[JSONDecoder decoder] objectWithData:[request responseData]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InquiryListRefresh" object:nil];
   // NSLog(@"data %@",data);
    kAppDelegate.HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
    
    // Set custom view mode
    kAppDelegate.HUD.mode = MBProgressHUDModeCustomView;
    kAppDelegate.HUD.animationType = MBProgressHUDAnimationZoom;
    kAppDelegate.HUD.labelText = @"保存成功!";
    
    [kAppDelegate.HUD show:YES];
    [kAppDelegate.HUD hide:YES afterDelay:1.5];
    [self performSelector:@selector(backAction) withObject:nil afterDelay:1.6];
}

-(void)backAction{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)loadView;
{
	[super loadView];
	UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] 
								 initWithTitle:@"保存"
								 style:UIBarButtonItemStyleDone
								 target:self action:@selector(inquiryUpdata)];
	self.navigationItem.rightBarButtonItem = rightItem;
	
	UITableView *formTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.frame.size.height) 
															   style:UITableViewStylePlain] autorelease];
    formTableView.delegate = self;
    
	[formTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	
	[self setTableView:formTableView];
	[self.view addSubview:formTableView];
}

@end