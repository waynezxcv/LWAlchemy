//
//  The MIT License (MIT)
//  Copyright (c) 2016 Wayne Liu <liuweiself@126.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//　　The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//
//
//
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAlchemy
//  See LICENSE for this sample’s licensing information
//

#import "ViewController.h"
#import "StatusModel.h"
#import "LWAlchemy.h"
#import "StatusEntity.h"
#import "UserEntity.h"
#import "TestEntity.h"
#import "SendViewController.h"


@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,assign) NSInteger refreshCount;
@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) NSMutableArray* dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                              target:self
                                              action:@selector(coredataUniqBatchInsert)];
    self.refreshCount = 0;
}

#pragma mark - LWAlchemy

//插入entity并设置unique 当unique对应的值已经存在时，不再重复插入，而是更新数据
- (void)coredataUniqBatchInsert {
    self.refreshCount ++;//刷新的次数
    NSMutableArray* fakeData = [[NSMutableArray alloc] init];
    NSInteger index = 0;
    for (NSInteger i = 0; i < 500; i ++) {
        NSString* text =  [NSString stringWithFormat:@"这是ID为%ld的数据第%ld次更新",index + i,self.refreshCount];//更新的内容。
        NSDictionary* dict = @{@"statusId":@(index + i),
                               @"text":text,
                               @"c_user" : @{@"c_name" :[NSString stringWithFormat:@"这是ID为%ld 的第二级Model",index + i],
                                             @"test":@{@"content":@"第三级映射。。。"}}
                               };
        [fakeData addObject:dict];
    }
    __weak typeof(self) wself = self;
    LWAlchemyManager* manager = [LWAlchemyManager sharedManager];
    [manager insertEntitysWithClass:[StatusEntity class]
                         JSONsArray:fakeData
                uiqueAttributesName:@"statusId"
                               save:YES
                         completion:^{
                                   //查询
                                   NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"statusId" ascending:YES];
                                   [manager fetchNSManagedObjectWithObjectClass:[StatusEntity class] predicate:nil
                                                                 sortDescriptor:@[sort]
                                                                    fetchOffset:0
                                                                     fetchLimit:0
                                                                    fetchReults:^(NSArray *results, NSError *error) {
                                                                        __strong typeof(wself) swself = wself;
                                                                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                                                            [swself.dataSource removeAllObjects];
                                                                            for (StatusEntity* entity in results) {
                                                                                [swself.dataSource addObject:entity];
                                                                            }
                                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                                [swself.tableView reloadData];
                                                                            });
                                                                        });
                                                                    }];
                               }];
}


//生成Model
- (void)modelWithJson {
    NSMutableArray* tmp = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 1; i ++) {
        NSDictionary* dict = @{@"liked":@NO,
                               @"statusId":@123456,
                               @"percent":@"3.1415926",
                               @"text" : @"使用LWAlchemy",
                               @"website":@"www.google.com",
                               @"likedCount":@9999,
                               @"imgs":@[@"1111",@"2222",@"3333"],
                               @"profileDict":@{@"key":@"value"},
                               @"timeStamp":@1458628616,
                               @"idContent":@"this is void* ",
                               @"c_user" : @{
                                       @"c_name" : @"Waynezxcv",
                                       @"c_sign" : @"这是我的签名",
                                       @"age":@(22),
                                       @"website":@"http://www.waynezxcv.me",
                                       @"test":@{@"content":@"第三级映射。。。"}
                                       },
                               @"retweetedStatus" : @{
                                       @"text" : @"LWAlchemy ORM",
                                       @"user" : @{
                                               @"name" : @"Wayne",
                                               @"sign" : @"just do it!",
                                               @"age": @(18),
                                               @"website":@"www.apple.com"
                                               }
                                       }
                               };
        [tmp addObject:dict];
    }
    NSDate* startTime = [NSDate date];
    for (NSDictionary* dict in tmp) {
        // 将字典转为Status模型
        StatusModel* status = [StatusModel modelWithJSON:dict];
    }
    NSLog(@"时间消耗: %f", -[startTime timeIntervalSinceNow]);
}

#pragma mark ---

- (UITableView *)tableView {
    if (_tableView) {
        return _tableView;
    }
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                              style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    return _tableView;
}

- (NSMutableArray *)dataSource {
    if (_dataSource) {
        return _dataSource;
    }
    _dataSource = [[NSMutableArray alloc] init];
    return _dataSource;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    StatusEntity* entity = [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = entity.text;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    StatusEntity* entity = [self.dataSource objectAtIndex:indexPath.row];
    UserEntity* user = entity.user;
    SendViewController* vc = [[SendViewController alloc] init];
    vc.user = user;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
