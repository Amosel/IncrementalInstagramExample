// ArtistsListViewController.m
//  Incremental Instagram Example
//
//  Copyright (c) 2012 Amos Elmaliah (http://amosel.org)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <CoreData/CoreData.h>
#import "PublicTimelineViewController.h"

// model:
#import "Picture.h"
#import "User.h"

// views
#import "PictureTableViewCell.h"
#import "PictureTableViewHeader.h"

@interface PublicTimelineViewController () <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *_fetchedResultsController;
}

- (void)refetchData;

@end

@implementation PublicTimelineViewController

- (void)refetchData {
    [_fetchedResultsController performSelectorOnMainThread:@selector(performFetch:) withObject:nil waitUntilDone:YES modes:@[ NSRunLoopCommonModes ]];
    [_fetchedResultsController performFetch:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Public Timeline", nil);
    [self.navigationController setNavigationBarHidden:YES];
    self.tableView.rowHeight = 70.0f;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Picture"];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO]];
    fetchRequest.fetchLimit = 50;
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:[(id)[[UIApplication sharedApplication] delegate] managedObjectContext]
                                                                      sectionNameKeyPath:@"id"
                                                                               cacheName:@"PublicTimeline"];
    _fetchedResultsController.delegate = self;
    [self refetchData];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refetchData)];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    PictureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[PictureTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
{
    @try {
        [(PictureTableViewCell *)cell setPicture:(Picture *)[_fetchedResultsController objectAtIndexPath:indexPath]];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [PictureTableViewCell heightForCellWithPicture:(Picture *)[_fetchedResultsController objectAtIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Picture* picture = [_fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    
    return [NSString stringWithFormat:@"%@", picture.user.fullname];
}

#pragma mark - NSFetchedResultsControllerDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    Picture* picture = [_fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    return [PictureTableViewHeader heightForCellWithPicture:picture];
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    Picture* picture = [_fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    PictureTableViewHeader* view = [[PictureTableViewHeader alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 20)];
    view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.25];
    [view setPicture:picture];
    return view;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

@end
