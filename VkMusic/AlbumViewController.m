//
//  AlbumViewController.m
//  VkMusic
//
//  Created by keepcoder on 12.04.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "AlbumViewController.h"
#import "BaseViewCell.h"
#import "Consts.h"
#import "MainViewController.h"
#import "UIImage+Extension.h"
#import "UIButton+Extension.h"
@interface AlbumViewController ()
@property (nonatomic,strong) MainViewController *controller;
@end

@implementation AlbumViewController
@synthesize toolbar;
@synthesize logic;
@synthesize viewList;
@synthesize controller = _controller;
@synthesize handler = _handler;
@synthesize menu;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        logic = [AlbumsLogic instance];
       
    }
    return self;
}

-(void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    [self.controller back];
}



-(void)add:(id)sender {
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"NEW_ALBUM",nil) message:NSLocalizedString(@"ENTER_ALBUM_NAME",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL",nil) otherButtonTitles:NSLocalizedString(@"CREATE",nil), nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av show];
    
}

-(void)setMainController:(UIViewController *)controller {
    self.controller = (MainViewController *)controller;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            // canceled
            break;
        case 1:
            if([[alertView textFieldAtIndex:0].text length] > 0)
                [logic createAlbumWithName:[alertView textFieldAtIndex:0].text];
            break;
        default:
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    viewList = [[BaseViewList alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    
    UIImage *ai = [UIImage imageNamed:@"plus_white.png"];
    UIButton *ab = [UIButton buttonWithType:UIButtonTypeCustom];
    [ab setHitTestEdgeInsets:UIEdgeInsetsMake(-20, -20, -20, -20)];
    ab.bounds = CGRectMake( 0, 0, ai.size.width, ai.size.height );
    [ab setImage:ai forState:UIControlStateNormal];
    [ab addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithCustomView:ab];

    menu = [[SINavigationMenuView alloc] initWithFrame:self.viewList.frame title:NSLocalizedString(@"ALBUMS", nil)];
    [menu displayMenuInView:self.view];
    menu.tableFrame = CGRectMake(0, toolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    
    
    
    menu.items = @[NSLocalizedString(@"ALL", nil), NSLocalizedString(@"DOWNLOADS", nil),NSLocalizedString(@"RECOMMENDS", nil),NSLocalizedString(@"ALBUMS", nil),NSLocalizedString(@"FRIENDS", nil)];
    
    if([Consts access] == NO) {
        menu.items = @[NSLocalizedString(@"ALL", nil),NSLocalizedString(@"RECOMMENDS", nil),NSLocalizedString(@"ALBUMS", nil),NSLocalizedString(@"FRIENDS", nil)];
    }
    
    menu.delegate = self.controller;
    
    UIBarButtonItem *leftFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *leftBtnFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftBtnFlex.width = ai.size.width;
    UIBarButtonItem *rightFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithCustomView:menu];

    title.tintColor = [UIColor clearColor];
    [title setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor grayColor], UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
      [UIColor whiteColor], UITextAttributeTextColor,
      [UIFont fontWithName:FONT_BOLD size:17.0], UITextAttributeFont,
      nil] forState:UIControlStateNormal];
    
    [self.toolbar setItems:[NSArray arrayWithObjects:leftBtnFlex,leftFlex,title,rightFlex, add, nil]];
    [self.toolbar setBackgroundColor:[UIColor blackColor]];
    
    self.viewList.separatorStyle  = UITableViewCellSeparatorStyleSingleLine;
    self.viewList.rowHeight       = DEFAULT_CELL_SIZE;
    
    self.viewList.delegate = self;
    self.viewList.dataSource = self;
    logic.controller.delegate = self;
    viewList.contentInset = UIEdgeInsetsMake(toolbar.frame.size.height, 0, 0, 0);
    [self.view addSubview:viewList];
    [self.view addSubview:toolbar];
    
   
}


-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadWithAnimation:UITableViewRowAnimationFade];
    });
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:YES completion:^{
         
    }];
    [self.viewList deselectRowAtIndexPath:indexPath animated:YES];
    _handler([[logic findAlbumByRow:indexPath.row].album_id integerValue]);
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [logic deleteAlbum:indexPath.row];
}


-(void)reloadWithAnimation:(UITableViewRowAnimation)animation {
    [self.viewList beginUpdates];
    [self.viewList reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:animation];
    [self.viewList endUpdates];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [logic albumList].count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Album *album = [logic findAlbumByRow:indexPath.row];
    static NSString *cellIdentifier = @"AlbumCell";
    BaseViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[BaseViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    
    cell.textLabel.text = album.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"TRACKS", nil),[logic albumCount:[album.album_id integerValue]]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    /*UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Редактирование" message:@"Введите название" delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:@"Сохранить", nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av show];*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
