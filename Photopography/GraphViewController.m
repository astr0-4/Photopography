//  Photopography
//
//  Created by Daniel Hooper on 2015-07-07.
//  Copyright (c) 2015 Daniel Hooper. All rights reserved.
//

#import "GraphViewController.h"
#import "FlickrPhotoViewController.h"
#import "APIKey.h"
#import "Total.h"

@interface GraphViewController ()

@property (strong, nonatomic) NSArray *firstDayOfMonthUNIX;
@property (strong, nonatomic) NSArray *lastDayOfMonthUNIX;
@property (strong, nonatomic) NSMutableArray *graphValuesMutableArray;
@property (strong, nonatomic) NSString *graphValue;

@property (strong, nonatomic) NSMutableArray *graphValuesArray;
@property (strong, nonatomic) NSArray *datesArray;

@end

@implementation GraphViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    BEMSimpleLineGraphView *myGraph = [[BEMSimpleLineGraphView alloc] init];
    myGraph.delegate = self;
    myGraph.dataSource = self;
    
    [self.view addSubview:myGraph];
    
    NSArray *firstDayOfMonthUNIX = @[@"1420070400", @"1422748800", @"1425168000", @"1427846400", @"1430438400", @"1433116800", @"1435708800", @"1438387200", @"1441065600", @"1443657600", @"1446336000", @"1448928000",];
    NSArray *lastDayOfMonthUNIX = @[@"1422748799", @"1425167999", @"1427846399", @"1430438399", @"1433116799", @"1435708799", @"1438387199", @"1441065599", @"1443657599", @"1446335999", @"1448927999", @"1451606399"];
    
    self.graphValuesArray = [[NSMutableArray alloc] init];
    
    int i;
    
    for (i = 0; i < 12; i++) {
        
        self.firstDay = firstDayOfMonthUNIX[i];
        self.lastDay = lastDayOfMonthUNIX[i];
        
        NSString *urlStringForDates = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&min_taken_date=%@&max_taken_date=%@&has_geo=1&lat=%f&lon=%f&radius=0.1&format=json&nojsoncallback=1", API_KEY, firstDayOfMonthUNIX[i], lastDayOfMonthUNIX[i], self.latitude, self.longitude];
        
        NSURL *urlDates = [NSURL URLWithString:urlStringForDates];
        NSLog(@"url: %@", urlDates);
        
        NSData *jsonData = [NSData dataWithContentsOfURL:urlDates];
        
        NSError *error = nil;
        
        NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        
        NSDictionary *photosDict = [dataDictionary objectForKey:@"photos"];
        
        NSString *totalString = [photosDict objectForKey:@"total"];
        
        NSLog(@"total: %@", totalString);
        
        [self.graphValuesArray addObject:totalString];
        
        // Number of points in the graph.
        NSLog (@"count: %lu", (unsigned long)self.graphValuesArray.count);
        NSLog (@"total from array: %@", self.graphValuesArray[i]);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.graphValuesArray.count;
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    return [[self.graphValuesArray objectAtIndex:index] floatValue];
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    self.datesArray = [[NSArray alloc] initWithObjects:@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec", nil];
    if ((index % 2) == 1) return [self.datesArray objectAtIndex:index];
    else return @"";
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
