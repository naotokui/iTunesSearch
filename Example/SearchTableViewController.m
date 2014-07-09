//
//  SearchTableViewController.m
//  Example
//
//  Created by Nao Tokui on 7/9/14.
//  Copyright (c) 2014 Gangverk. All rights reserved.
//

#import "SearchTableViewController.h"
#import "ItunesSearch.h"
#import "AsyncImageView.h"

@interface SearchTableViewController ()

@property (strong, nonatomic) UISearchBar   *searchBar;
@property (strong, nonatomic) NSArray       *searchResults;

@end

@implementation SearchTableViewController
{
    dispatch_semaphore_t  semaphore;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"iTunes Search";
    
    // Search bar
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    self.searchBar.placeholder = NSLocalizedString(@"iTunes Store", nil);
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.delegate = self;
    
    [self.tableView addSubview: self.searchBar];
    [self.tableView setContentOffset:CGPointMake(0, 44)];
    
    semaphore = dispatch_semaphore_create(1);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    [self.tableView scrollRectToVisible: CGRectMake(0, 44, 100, 10) animated:YES];
    [self.searchBar becomeFirstResponder];
}

#pragma mark - Search bar


-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setText:@""];
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    //    [self searchGIFImages: searchBar.text];
    //    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchItunes: searchBar.text];
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self searchItunes: searchBar.text];
    [searchBar resignFirstResponder];
}


- (void) searchItunes: (NSString *)keyword
{
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC);
    long result = dispatch_semaphore_wait(semaphore, time);
    if (result == 0){
        [[ItunesSearch sharedInstance] getTrackWithName: keyword artist: @"" album:@"" limitOrNil:nil
                                         successHandler:
         ^(NSArray *result) {
             NSLog(@"result: %@", result);
             self.searchResults = result;
             
             [self.tableView reloadData];
         } failureHandler:^(NSError *error) {
             NSLog(@"error: %@", error);
         }];
        
        dispatch_semaphore_signal(semaphore);
    } else {
        NSLog(@"semaphore time out");
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchResults count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell"];
    static int tag = 3333;
    
    UIImage *placeholder =  [UIImage imageNamed: @"img_no_cover"]; // placeholder image
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: @"Cell"];
        
        cell.imageView.image = placeholder;
        AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame: CGRectMake(10, 2, 40, 40)];
        imageView.image = placeholder;
        imageView.tag = tag;
        [cell.contentView addSubview: imageView];
        cell.imageView.hidden = YES; 
    }
    
    if ([self.searchResults count] > indexPath.row){
        NSDictionary *songInfo = [self.searchResults objectAtIndex: indexPath.row];
        NSString *artist    = songInfo[@"artistName"];
        NSString *song      = songInfo[@"trackName"];
        NSString *album     = songInfo[@"collectionName"];
        NSString *artwork   = songInfo[@"artworkUrl60"];
        
        cell.textLabel.text = song;
        cell.detailTextLabel.text = [NSString stringWithFormat: @"%@ (%@)", artist, album];
        
        AsyncImageView *imageView   = (AsyncImageView *)[cell viewWithTag: tag];
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: imageView];
        imageView.image                 = placeholder; // clear with placeholder image
        imageView.imageURL              = [NSURL URLWithString: artwork];
    }
    
    // Configure the cell...
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
