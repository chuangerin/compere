//
//  InputViewController.m
//  Compere
//
//  Created by Erin Chuang on 12/14/16.
//  Copyright © 2016 Kimi Wu. All rights reserved.
//

#import "InputViewController.h"
#import "SuggestionCollectionViewCell.h"

static CGFloat const kCellHeight = 38.f;
static CGFloat const kHorizontalMargin = 10.f;

static NSString * const kAuthor = @"Guest";

@interface InputViewController ()
<
UITextFieldDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) NSArray *questionPrefixes;
@property (strong, nonatomic) NSArray *suggestions;

@end

@implementation InputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.textField.delegate = self;
    [self setupCollectionView];
    self.questionPrefixes = @[@"what",@"why",@"how",@"when",@"who"];
    self.suggestions = @[@"suggestion 1 ", @"suggestion 2", @"suggestion 3"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPostTapped:(id)sender {
    NSString *text = self.textField.text;
    if (text && text.length) {
        if (self.delegate) {
            MessageDataObject *message = [[MessageDataObject alloc] initWithAuthor:kAuthor content:text isQuestion:[self isAQuestion:text] voteScore:@"" textId:@""];
            [self.delegate onUserPostMessage:message];
        }
        //TODO: api call to post text
    }
    
    [self.collectionView setHidden:YES];
    [self.textField resignFirstResponder];
    self.textField.text = @"";
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length >= 3) {
        if (string.length > 0 && ![string isEqualToString:@"\n"]) {
            // TODO: api call to fetch suggestions & display suggestion view
        }
        // TODO: refactor once api is ready
        if (self.collectionView.isHidden) {
            CGRect rect = self.collectionView.frame;
            rect.size.height = self.suggestions.count * kCellHeight;
            rect.origin.y = -rect.size.height;
            self.collectionView.frame = rect;
            [self.collectionView reloadData];
            [self.collectionView setHidden:NO];
        }
    } else {
        // TODO: hide suggestion view
        [self.collectionView setHidden:YES];
    }
    return YES;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return self.suggestions.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SuggestionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[SuggestionCollectionViewCell cellReuseIdentifier] forIndexPath:indexPath];
    cell.suggestionLabel.text = self.suggestions[indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(collectionView.bounds)-kHorizontalMargin*2.f, kCellHeight);
}

#pragma mark - private methods
- (void)setupCollectionView
{
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumInteritemSpacing = 0.0f;
    layout.minimumLineSpacing = 0.0f;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, width, 0) collectionViewLayout:layout];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    self.collectionView.contentInset = UIEdgeInsetsMake(0, kHorizontalMargin, 0, kHorizontalMargin);
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView setHidden:YES];
    
    [self.collectionView registerNib:[UINib nibWithNibName:[SuggestionCollectionViewCell cellReuseIdentifier] bundle:nil] forCellWithReuseIdentifier:[SuggestionCollectionViewCell cellReuseIdentifier]];
    
    [self.view addSubview:self.collectionView];
}

- (BOOL)isAQuestion:(NSString*)text
{
    if ([text hasSuffix:@"?"]) {
        return YES;
    }
    __block BOOL isQuestion = NO;
    [self.questionPrefixes enumerateObjectsUsingBlock:^(NSString * _Nonnull prefix, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([text hasPrefix:prefix]) {
            isQuestion = YES;
            *stop = YES;
        }
    }];
    return isQuestion;
}

@end
