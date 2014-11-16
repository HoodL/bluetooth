//
//  TIBLECBKeyfob.h
//  Created by Tony on 10/22/2012.
//  Copyright (c) 2012 Jess Tech. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>
#import "BleDefines.h"


@protocol BleControlDelegate
@optional
-(void) keyfobReady;
-(void) accelerometerValuesUpdated:(char)x y:(char)y z:(char)z;
-(void) keyValuesUpdated:(char)sw;
-(void) TXPwrLevelUpdated:(char)TXPwr;
-(void) setButtonState;

//pedometer //计步器绑定uuid
-(void) BindWithUUID:(NSString*)strUUID;
//@required
-(void)SetDevice:(NSString*)device_name Status:(NSString*)status;
-(void)Stop;
-(void)ScanStop;
-(void)DisplayRece:(unsigned char*)buf length:(int)len;
-(void)Disconnected;
-(void)AddTableView;
-(void)startPhoto;
-(void)ShowPercent:(float)battery;
//蓝牙正常断开
-(void)WellDisconnected;


//test
-(void)bindWithPeripheral:(CBPeripheral*)device;




@end

@interface BleControl : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate,CBPeripheralManagerDelegate> {
    BOOL b_restrieve;
   
    NSString * strUUID;
}

@property(nonatomic,retain) NSString * strUUID;
@property (nonatomic)   float batteryLevel;
@property (nonatomic)   BOOL key1;
@property (nonatomic)   BOOL key2;
@property (nonatomic)   char x;
@property (nonatomic)   char y;
@property (nonatomic)   char z;
@property (nonatomic)   char TXPwrLevel;


@property (nonatomic,assign) id <BleControlDelegate> delegate;
@property (strong, nonatomic)  NSMutableArray *peripherals;
@property (strong ,nonatomic) NSMutableArray * arrayRSSI;
@property (strong, nonatomic) CBCentralManager *CM;
@property (strong, nonatomic)CBPeripheralManager * manager;
@property (strong, nonatomic) CBPeripheral *activePeripheral;

-(void) soundBuzzer:(Byte)buzVal p:(CBPeripheral *)p;
-(void) readBattery:(CBPeripheral *)p;
-(void) enableAccelerometer:(CBPeripheral *)p;
-(void) disableAccelerometer:(CBPeripheral *)p;
-(void) enableButtons:(CBPeripheral *)p;
-(void) disableButtons:(CBPeripheral *)p;
-(void) enableTXPower:(CBPeripheral *)p;
-(void) disableTXPower:(CBPeripheral *)p;
-(void)enableIAlarm:(CBPeripheral*)p;
-(void)disableIAlarm:(CBPeripheral*)p;

/*****/
-(void)enbleWriteData:(CBPeripheral*)p;
-(void)enbleReadData:(CBPeripheral*)p;

-(void)enableRead:(CBPeripheral*)p;
-(void)DisableRead:(CBPeripheral*)p;
-(void)disenablePhoto:(CBPeripheral*)p;
-(void)enablePhoto:(CBPeripheral*)p;


-(void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID  p:(CBPeripheral *)p data:(NSData *)data;
-(void) readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID  p:(CBPeripheral *)p;
-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID  p:(CBPeripheral *)p on:(BOOL)on;

-(void) setPeripheralManager;
-(UInt16) swap:(UInt16) s;
-(int) controlSetup:(int) s;
-(int) findBLEPeripherals:(int) timeout;
-(const char *) centralManagerStateToString:(int)state;
-(void) scanTimer:(NSTimer *)timer;
-(void) printKnownPeripherals;
-(void) printPeripheralInfo:(CBPeripheral*)peripheral;
-(void) connectPeripheral:(CBPeripheral *)peripheral;
-(void) disconnect:(CBPeripheral*)peripheral;//断开连接


-(void) getAllServicesFromKeyfob:(CBPeripheral *)p;
-(void) getAllCharacteristicsFromKeyfob:(CBPeripheral *)p;
-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p;
-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service;
-(const char *) UUIDToString:(CFUUIDRef) UUID;
-(const char *) CBUUIDToString:(CBUUID *) UUID;
-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2;
-(int) compareCBUUIDToInt:(CBUUID *) UUID1 UUID2:(UInt16)UUID2;
-(UInt16) CBUUIDToInt:(CBUUID *) UUID;
-(int) UUIDSAreEqual:(CFUUIDRef)u1 u2:(CFUUIDRef)u2;

-(void)retrieveConnect:(CBUUID*)uuid;




@end
