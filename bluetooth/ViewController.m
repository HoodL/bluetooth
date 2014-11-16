//
//  CBCenterViewController.m
//  BluetoothTest
//
//  Created by Pro on 14-4-6.
//  Copyright (c) 2014年 Pro. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "ViewController.h"
@interface ViewController ()

@end
@implementation ViewController
@synthesize cell;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"防丢器";
        //self.tabBarItem.image = [UIImage imageNamed:@"lock.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *topView=[[UIView alloc]initWithFrame:CGRectMake(0, 20, kDeviceWidth, 44)];
    [self.view addSubview:topView];
    topView.backgroundColor=[UIColor redColor];
    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight)];
    scroll.contentSize = CGSizeMake(kDeviceWidth, kDeviceHeight*2);
   // [self.view addSubview:scroll];
    
    //    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation.png"] forBarMetrics:UIBarMetricsDefault];
    UIButton *leftButton=[[UIButton alloc]initWithFrame:CGRectMake(10, 0, 44, 44)];
    [leftButton addTarget:self action:@selector(scanClick) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:leftButton];
    UILabel *label1=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    label1.text=@"扫描";
    label1.textColor=[UIColor whiteColor];
    label1.textAlignment=NSTextAlignmentCenter;
    [leftButton addSubview:label1];
    
    UIButton *rightButton=[[UIButton alloc]initWithFrame:CGRectMake(kDeviceWidth-54, 0, 44, 44)];
    [rightButton addTarget:self action:@selector(clearData) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:rightButton];
    UILabel *label2=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    label2.text=@"清屏";
    label2.textColor=[UIColor whiteColor];
    label2.textAlignment=NSTextAlignmentCenter;
    [rightButton addSubview:label2];
    
    UIBarButtonItem *rightAction = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(selectRightAction:)];
    self.navigationItem.rightBarButtonItem = rightAction;
    
    UIImageView *backView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"back3.png"]];
    backView.frame = CGRectMake(0, 0, kDeviceWidth, kDeviceHeight);
    [scroll addSubview:backView];
    
    _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    UIButton *scan = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [scan setTitle:@"扫描" forState:UIControlStateNormal];
    scan.frame = CGRectMake(20, 210, 60, 30);
    [scan addTarget:self action:@selector(scanClick) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:scan];
    
    _connect = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_connect setTitle:@"连接" forState:UIControlStateNormal];
    _connect.frame = CGRectMake(90, 210, 60, 30);
    [_connect addTarget:self action:@selector(connectClick:) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:_connect];
    
    UIButton *send = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [send setTitle:@"报警" forState:UIControlStateNormal];
    send.frame = CGRectMake(160, 210, 60, 30);
    [send addTarget:self action:@selector(sendClick:) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:send];
    
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 250, 300, 200)];
    //[scroll addSubview:_textView];
    
    _cbReady = false;
    _nDevices = [[NSMutableArray alloc]init];
    _nServices = [[NSMutableArray alloc]init];
    _nCharacteristics = [[NSMutableArray alloc]init];
    
    _deviceTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kDeviceWidth, kDeviceHeight-64-200) style:UITableViewStylePlain];
    UIImageView *imageView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"back2.png"]];
    imageView.layer.cornerRadius = 10;
    imageView.layer.masksToBounds = YES;
    _deviceTable.backgroundView = imageView;
    _deviceTable.delegate = self;
    _deviceTable.dataSource = self;
    _deviceTable.scrollEnabled=YES;
    _deviceTable.autoresizingMask=YES;
    _deviceTable.autoresizesSubviews=YES;
    
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, kDeviceHeight-200, kDeviceWidth, 200)];
    view.backgroundColor=[UIColor redColor];
    [self.view addSubview:view];
    
    self.timeField=[[UITextField alloc]initWithFrame:CGRectMake(50, 15, 220, 30)];
    self.timeField.borderStyle=UITextBorderStyleBezel;
    _timeField.textAlignment=NSTextAlignmentCenter;
    _timeField.userInteractionEnabled=NO;
    [view addSubview:_timeField];
    
    UIButton *synButton=[[UIButton alloc]initWithFrame:CGRectMake(100, 65, 120, 30)];
    [synButton setTitle:@"同步时间" forState:UIControlStateNormal];
    [synButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [synButton addTarget:self action:@selector(synTime) forControlEvents:UIControlEventTouchUpInside];
    
    synButton.backgroundColor=[UIColor greenColor];
    [view addSubview:synButton];
    
    UIButton *realTimeButton=[[UIButton alloc]initWithFrame:CGRectMake(75, 115, 80, 30)];
    [realTimeButton setTitle:@"实时" forState:UIControlStateNormal];
    [realTimeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [realTimeButton addTarget:self action:@selector(getRealTimeData) forControlEvents:UIControlEventTouchUpInside];
    realTimeButton.backgroundColor=[UIColor orangeColor];
    [view addSubview:realTimeButton];
    
    UIButton *historyButton=[[UIButton alloc]initWithFrame:CGRectMake(185, 115, 80, 30)];
    [historyButton setTitle:@"历史" forState:UIControlStateNormal];
    [historyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [historyButton addTarget:self action:@selector(getHistoryData) forControlEvents:UIControlEventTouchUpInside];
    historyButton.backgroundColor=[UIColor orangeColor];
    [view addSubview:historyButton];
    
    UIButton *endButton=[[UIButton alloc]initWithFrame:CGRectMake(100, 165, 120, 30)];
    [endButton setTitle:@"结束" forState:UIControlStateNormal];
    [endButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [endButton addTarget:self action:@selector(endGetRealTimeData) forControlEvents:UIControlEventTouchUpInside];
    endButton.backgroundColor=[UIColor greenColor];
    [view addSubview:endButton];
    
    [self setUpTime];
    [self.view addSubview:_deviceTable];
    //刷新指示圈
        _activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activity.frame = CGRectMake(140, 0, 44, 44);
        _activity.hidesWhenStopped = YES;
    _activity.color=[UIColor blueColor];
        [topView addSubview:_activity];
    
}
-(void)setUpTime {
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(NowDate) userInfo:nil repeats:YES];
}

-(void)NowDate
{
    NSString* date;
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    date = [formatter stringFromDate:[NSDate date]];
    _timeField.text =date;
}

-(void) synTime
{
    if((_peripheral.state==CBPeripheralStateConnected))
    {
        NSDate * Now = [NSDate date];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        NSInteger unitFlags = NSYearCalendarUnit |
        NSMonthCalendarUnit |
        NSDayCalendarUnit |
        NSWeekdayCalendarUnit |
        NSHourCalendarUnit |
        NSMinuteCalendarUnit |
        NSSecondCalendarUnit;
        comps = [calendar components:unitFlags fromDate:Now];
        int year = [comps year]%100;//year=14
        NSInteger month = [comps month];
        NSInteger day = [comps day];
        NSInteger hour = [comps hour];
        NSInteger min = [comps minute];
        NSInteger sec =  [comps second];
        uint8_t  SetYear = (year/10)*16+year%10;
        uint8_t SetMonth = (month/10)*16+month%10;
        uint8_t SetDay = (day/10)*16+day%10;
        uint8_t SetHour = (hour/10)*16+hour%10;
        uint8_t SetMin = (min/10)*16+min%10;
        uint8_t SetSec = (sec/10)*16+sec%10;
        uint8_t b[] = {0xAA,0x07,0x00,SetYear,SetMonth,SetDay,SetHour,SetMin,SetSec,0x07+0x00+SetYear+SetMonth+SetDay+SetHour+SetSec+SetMin,0x55};
        NSMutableData *data = [[NSMutableData alloc] initWithBytes:b length:11];
        [self writeValue:0x1814 characteristicUUID:0x2A53 p:_peripheral data:data];
    }
}

-(void)getRealTimeData
{
    uint8_t b[]={0xAA,0x02,0x01,0x00,0x03,0x55};
    NSMutableData *data=[[NSMutableData alloc]initWithBytes:b length:6];
    [self writeValue:0x1814 characteristicUUID:0x2A53 p:_peripheral data:data];
    
}
-(void)getHistoryData {
    uint8_t b[]={0xAA,0x02,0x02,0x00,0x04,0x55};
    NSMutableData *data=[[NSMutableData alloc]initWithBytes:b length:6];
    [self writeValue:0x1814 characteristicUUID:0x2A53 p:_peripheral data:data];
    
}
-(void)endGetRealTimeData
{
    uint8_t b[]={0xAA,0x02,0x01,0x01,0x04,0x55};
    NSMutableData *data=[[NSMutableData alloc]initWithBytes:b length:6];
    [self writeValue:0x1814 characteristicUUID:0x2A53 p:_peripheral data:data];
}
-(void)clearData
{
    [_nDevices removeAllObjects];
    [_deviceTable reloadData];
}
-(void)reloadData
{
    _isRefreshing  = YES;
    [NSThread detachNewThreadSelector:@selector(requestData) toTarget:self withObject:nil];
}

-(void)requestData
{
    [_nDevices addObject:@"我是蓝牙设备"];
    sleep(1.0);
    [self performSelectorOnMainThread:@selector(refreshUI) withObject:self waitUntilDone:NO];
}

-(void)refreshUI
{
    [_deviceTable reloadData];
}



#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    }
    else  {
    return [_nDevices count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identified = [NSString stringWithFormat:@"Cell%ld%ld",(long)[indexPath section],(long)[indexPath row]];
    if(indexPath.section == 0)
    {
       UITableViewCell* cell1 = [tableView dequeueReusableCellWithIdentifier:identified];
        if (cell1 == nil) {
            cell1 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identified];
        }
        self.mytextField=[[UITextField alloc]initWithFrame:CGRectMake(20, 15, 120, 20)];
        self.mytextField.borderStyle=UITextBorderStyleRoundedRect;
        self.mytextField.delegate=self;
        [cell1 addSubview:self.mytextField];
        
        UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(200, 15, 50, 20)];
        button.backgroundColor=[UIColor redColor];
        [button setTitle:@"发送" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(sendData) forControlEvents:UIControlEventTouchUpInside];
        
        [cell1 addSubview:button];
        
        return cell1;
    }
    
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:identified];
        if (cell == nil) {
            cell = [[TableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identified];
        }
        CBPeripheral *p = [_nDevices objectAtIndex:indexPath.row];
        cell.textLabel.text = p.name;
        cell.detailTextLabel.text=p.identifier.UUIDString;
        [cell.connectButton addTarget:self action:@selector(connectClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.connectButton.tag=[indexPath row];
        return cell;
    }
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return @"已扫描到的设备:";
//}

//textView更新
-(void)updateLog:(NSString *)s
{
    static unsigned int count = 0;
    [_textView setText:[NSString stringWithFormat:@"[ %d ]  %@\r\n%@",count,s,_textView.text]];
    count++;
}
//实现代理方法
-(void)selectCategary:(NSString *)name
{
    //_nameLabel.text = name;
}
//扫描
-(void)scanClick
{
    NSArray *uuidArray = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"1814"],nil];
    
//    [self updateLog:@"正在扫描外设..."];
    [_activity startAnimating];
    [_manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
    double delayInSeconds = 10.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.manager stopScan];
        [_activity stopAnimating];
        [self updateLog:@"扫描超时,停止扫描"];
    });
}

//连接

-(void)connectClick:(id)sender
{
    UIButton *btn=(UIButton*)sender;
    
    if (_cbReady ==false) {
        [self.manager connectPeripheral:[_nDevices objectAtIndex:btn.tag] options:nil];
        
        _connectTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(connectTimeout:) userInfo:[_nDevices objectAtIndex:btn.tag] repeats:NO];
        _cbReady = true;
        
        [sender setTitle:@"断开" forState:UIControlStateNormal];
        
        //[_deviceTable reloadData];
    }else {
        [self.manager cancelPeripheralConnection:[_nDevices objectAtIndex:btn.tag]];
        _cbReady = false;
        [sender setTitle:@"连接" forState:UIControlStateNormal];
        [_deviceTable reloadData];
        
    }
}

//报警
-(void)sendClick:(UIButton *)bu
{
    unsigned char data = 0x02;
    [_peripheral writeValue:[NSData dataWithBytes:&data length:1] forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

//开始查看服务，蓝牙开启
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            [self updateLog:@"蓝牙已打开,请扫描外设"];
            break;
        default:
            break;
    }
}

//查到外设后，停止扫描，连接设备
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    //[self.manager stopScan];
    //[_activity stopAnimating];
    
    if(![_nDevices containsObject:peripheral])
    {
        [_nDevices addObject:peripheral];
        [_deviceTable reloadData];
        
        NSLog(@"%@",[NSString stringWithFormat:@"已发现 peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral, RSSI,
                     peripheral.identifier.UUIDString,advertisementData]);
        // _peripheral = peripheral;
        NSLog(@"%@",_peripheral);
        NSLog(@"name=%@,state=%d",peripheral.name,peripheral.state);
    }
//    BOOL replace = NO;
//    // Match if we have this device from before
//    for (int i=0; i < _nDevices.count; i++) {
//        CBPeripheral *p = [_nDevices objectAtIndex:i];
//        if ([p isEqual:peripheral]) {
//            [_nDevices replaceObjectAtIndex:i withObject:peripheral];
//            replace = YES;
//        }
//    }
//    if (!replace) {
//        NSLog(@"%@",[NSString stringWithFormat:@"已发现 peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral, RSSI,
//                     peripheral.identifier.UUIDString,advertisementData]);
//        // _peripheral = peripheral;
//        NSLog(@"%@",_peripheral);
//        NSLog(@"name=%@,state=%ld",peripheral.name,peripheral.state);
//        [_nDevices addObject:peripheral];
//        [_deviceTable reloadData];
//    }
}
//连接外设成功，开始发现服务
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
     [_connectTimer invalidate];
    NSLog(@"%@",[NSString stringWithFormat:@"成功连接 peripheral: %@ with UUID: %@",peripheral,peripheral.identifier.UUIDString]);
    _peripheral = peripheral;

    [self.peripheral setDelegate:self];
    [self.peripheral discoverServices:nil];
    NSLog(@"扫描服务");
    
}
//连接外设失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%@",error);
}

-(void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    //NSLog(@"%s,%@",__PRETTY_FUNCTION__,peripheral);
    int rssi = abs([peripheral.RSSI intValue]);
    CGFloat ci = (rssi - 49) / (10 * 4.);
    NSString *length = [NSString stringWithFormat:@"发现BLT4.0热点:%@,距离:%.1fm",_peripheral,pow(10,ci)];
    NSLog(@"距离：%@",length);
}

//已发现服务
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
    NSLog(@"发现服务.");
    int i=0;
    for (CBService *s in peripheral.services) {
        [self.nServices addObject:s];
    }
    for (CBService *s in peripheral.services) {
        NSLog(@"%@",[NSString stringWithFormat:@"%d :服务 UUID: %@(%@)",i,s.UUID.data,s.UUID]);
        i++;
        [peripheral discoverCharacteristics:nil forService:s];
    }
}

//已搜索到Characteristics
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
     NSLog(@"%@",[NSString stringWithFormat:@"发现特征的服务:%@ (%@)",service.UUID.data ,service.UUID]);
    
    for (CBCharacteristic *c in service.characteristics) {
        NSLog(@"%@",[NSString stringWithFormat:@"特征 UUID: %@ (%@)",c.UUID.data,c.UUID]);
        
        if ([c.UUID isEqual:[CBUUID UUIDWithString:@"2A53"]]) {
            _writeCharacteristic = c;
            NSLog(@"characteristic.properties=%d",c.properties);
            [_peripheral setNotifyValue:YES forCharacteristic:_writeCharacteristic];
        }
        
        if ([c.UUID isEqual:[CBUUID UUIDWithString:@"2A53"]]) {
            [_peripheral readValueForCharacteristic:c];
        }
        
        if ([c.UUID isEqual:[CBUUID UUIDWithString:@"2A53"]]) {
            [_peripheral readRSSI];
        }
        [_nCharacteristics addObject:c];
    }
}

//获取外设发来的数据，不论是read和notify,获取数据都是从这个方法中读取。
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"characteristic=%@",characteristic);
    UInt16 characteristicUUID = [self CBUUIDToInt:characteristic.UUID];
    //int length=[characteristic.value length];
    if (!error) {
        switch (characteristicUUID) {
            case 0x2A53:
            {
                uint8_t buf[4096] = {0};
                [characteristic.value getBytes:buf];
                
                if (buf[2]==0x00) {
                    if (buf[3]==0x01) {
                        NSLog(@"同步时间成功!");
                    }
                    else NSLog(@"同步时间失败");
                }
               else  if (buf[2]==0x01) {
                   if (buf[3]==0x00) {
                       uint8_t count1=buf[4];
                       uint8_t count2=buf[5];
                       NSInteger count=count1*16*16+count2;
                       NSInteger Amplitude=buf[6];
                       NSInteger frequency=buf[7];
                       NSLog(@"实时次数为%ld",(long)count);
                       NSLog(@"实时幅度为%ld",(long)Amplitude);
                       NSLog(@"实时频率为%ld",(long)frequency);
                   }
                   else {
                       NSLog(@"实时传输结束");
                   }
                }
                
              else if (buf[2]==0x02)
              {
                  if (buf[3]==0x00) {
                      NSLog(@"较早一次运动开始时间");
                  }
                  else if (buf[3]==0x01) {
                      NSLog(@"传输较早一次历史运动数据");
                  }
                  else if(buf[3]==0x02) {
                      NSLog(@"传输较早一次运动结束时间及运动综合参数");
                  }
                  else if(buf[3]==0x10) {
                      NSLog(@"较近一次运动开始时间");
                  }
                  else if (buf[3]==0x11) {
                      NSLog(@"传输较近一次历史运动数据");
                  }
                  else if(buf[3]==0x12)  {
                      NSLog(@"传输较近一次运动结束时间及运动综合参数");

                  }
              }
                
            }
                break;
            default:
                break;
        }
    }
//        }
//    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A53"]])
//    {
//    NSString *value = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//        NSLog(@"value=%@",value);
//        
//    }
//    else
//        NSLog(@"didUpdateValueForCharacteristic%@",[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
}
-(UInt16) CBUUIDToInt:(CBUUID *) UUID {
    char b1[16];
    [UUID.data getBytes:b1];
    return ((b1[0] << 8) | b1[1]);
}


//中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"Error changing notification state: %@", error.localizedDescription);

    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    // Notification has started
    if (characteristic.isNotifying) {
        [peripheral readValueForCharacteristic:characteristic];
        
    } else { // Notification has stopped
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self.manager cancelPeripheralConnection:self.peripheral];
    }
}

//用于检测中心向外设写数据是否成功
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"error=%@",error);
    if (error)
    {
        NSLog(@"发送数据失败");
        NSLog(@"error=======%@",error.userInfo);
    }else{
        NSLog(@"发送数据成功");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)sendData{
//if([blePeriphral isConnected]){
    NSString *name=self.mytextField.text;
    if(self.peripheral.state==CBPeripheralStateConnected){
    Byte CRC= 0;
    uint8_t a[] = {0xAA,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',CRC};
    for (int i =0; i<name.length; i++) {
        a[i+1] = [name characterAtIndex:i];
    }
    
    for(int i = 0; i<15;i++)
    {
        
        CRC += a[i];
    }
    CRC &=0xff;
    a[15]= CRC;
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:a length:16];
    [self writeValue:0x1814 characteristicUUID:0x2A53 p:self.peripheral data:data];
  }
}

-(void)writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data
{
    //NSLog(@"WRITE:====:%04X, %04X", serviceUUID, characteristicUUID);
    
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        NSLog(@"Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    
    //    [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse]; //TI
    [p writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];  //ISSC
    NSLog(@"data=%@",data);

}


-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil; //Characteristic not found on this service
}
-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p
{
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
    return nil; //Service not found on this peripheral
}

-(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2 {
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1];
    [UUID2.data getBytes:b2];
    int n = memcmp(b1, b2, UUID1.data.length);
    if (n == 0)return 1;
    else return 0;
}

-(const char *) UUIDToString:(CFUUIDRef)UUID {
    if (!UUID) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, UUID);
    return CFStringGetCStringPtr(s, 0);
    
}

-(const char *) CBUUIDToString:(CBUUID *) UUID {
    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
