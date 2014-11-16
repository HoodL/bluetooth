//
//  TIBLECBKeyfob.m
//  Created by Tony on 10/22/2012.
//  Copyright (c) 2012 Jess Tech. All rights reserved.
#import "BleControl.h"
extern CBPeripheral *StoreperipheralForPhoto;
extern CBPeripheral * blePeriphral;
CBMutableService  * servicea;//蓝牙服务
int alreadyConnect;
int  boolBle;

@implementation BleControl
@synthesize strUUID;

@synthesize delegate;
@synthesize CM,manager;
@synthesize peripherals;
@synthesize activePeripheral;
@synthesize batteryLevel;
@synthesize key1;
@synthesize key2;
@synthesize x;
@synthesize y;
@synthesize z;
@synthesize TXPwrLevel;


#if 0

#else


#endif


/*!
 *  @method soundBuzzer:
 *
 *  @param buzVal The data to write
 *  @param p CBPeripheral to write to
 *
 *  @discussion Sound the buzzer on a TI keyfob. This method writes a value to the proximity alert service
 *
 */
-(void) soundBuzzer:(Byte)buzVal p:(CBPeripheral *)p {
    NSData *d = [[NSData alloc] initWithBytes:&buzVal length:_PROXIMITY_ALERT_WRITE_LEN];
    [self writeValue:_PROXIMITY_ALERT_UUID characteristicUUID:_PROXIMITY_ALERT_PROPERTY_UUID p:p data:d];
}

/*!
 *  @method readBattery:
 *
 *  @param p CBPeripheral to read from
 *
 *  @discussion Start a battery level read cycle from the battery level service 
 *
 */
-(void) readBattery:(CBPeripheral *)p
{
    [self readValue:_BATT_SERVICE_UUID characteristicUUID:_LEVEL_SERVICE_UUID p:p];
}

// 

/*!
 *  @method enableAccelerometer:
 *
 *  @param p CBPeripheral to write to
 *
 *  @discussion Enables the accelerometer and enables notifications on X,Y and Z axis
 *
 */
-(void) enableAccelerometer:(CBPeripheral *)p {
    char data = 0x01;
    NSData *d = [[NSData alloc] initWithBytes:&data length:1];
    [self writeValue:_ACCEL_SERVICE_UUID characteristicUUID:_ACCEL_ENABLER_UUID p:p data:d];
    [self notification:_ACCEL_SERVICE_UUID characteristicUUID:_ACCEL_X_UUID p:p on:YES];
    [self notification:_ACCEL_SERVICE_UUID characteristicUUID:_ACCEL_Y_UUID p:p on:YES];
    [self notification:_ACCEL_SERVICE_UUID characteristicUUID:_ACCEL_Z_UUID p:p on:YES];
    NSLog(@"Enabling accelerometer\r\n");
}

/*!
 *  @method disableAccelerometer:
 *
 *  @param p CBPeripheral to write to
 *
 *  @discussion Disables the accelerometer and disables notifications on X,Y and Z axis
 *
 */
-(void) disableAccelerometer:(CBPeripheral *)p {
    char data = 0x00;
    NSData *d = [[NSData alloc] initWithBytes:&data length:1];
    [self writeValue:_ACCEL_SERVICE_UUID characteristicUUID:_ACCEL_ENABLER_UUID p:p data:d];
    [self notification:_ACCEL_SERVICE_UUID characteristicUUID:_ACCEL_X_UUID p:p on:NO];
    [self notification:_ACCEL_SERVICE_UUID characteristicUUID:_ACCEL_Y_UUID p:p on:NO];
    [self notification:_ACCEL_SERVICE_UUID characteristicUUID:_ACCEL_Z_UUID p:p on:NO];
    NSLog(@"Disabling accelerometer\r\n");
}


/*!
 *  @method enableButtons:
 *
 *  @param p CBPeripheral to write to
 *
 *  @discussion Enables notifications on the simple keypress service
 *
 */
-(void) enableButtons:(CBPeripheral *)p {
    [self notification:_KEYS_SERVICE_UUID characteristicUUID:_KEYS_NOTIFICATION_UUID p:p on:YES];
}




/*!
 *  @method disableButtons:
 *
 *  @param p CBPeripheral to write to
 *
 *  @discussion Disables notifications on the simple keypress service
 *
 */
-(void) disableButtons:(CBPeripheral *)p {
    [self notification:_KEYS_SERVICE_UUID characteristicUUID:_KEYS_NOTIFICATION_UUID p:p on:NO];
}



/*!
 *  @method enableTXPower:
 *
 *  @param p CBPeripheral to write to
 *
 *  @discussion Enables notifications on the TX Power level service
 *
 */
-(void) enableTXPower:(CBPeripheral *)p {
//    [self notification:_PROXIMITY_TX_PWR_SERVICE_UUID characteristicUUID:_PROXIMITY_TX_PWR_NOTIFICATION_UUID p:p on:YES];
     [self readValue:_PROXIMITY_TX_PWR_SERVICE_UUID characteristicUUID:_PROXIMITY_TX_PWR_NOTIFICATION_UUID p:p];
    
}

/*!
 *  @method disableTXPower:
 *
 *  @param p CBPeripheral to write to
 *
 *  @discussion Disables notifications on the TX Power level service
 *
 */
-(void) disableTXPower:(CBPeripheral *)p {
    [self notification:_PROXIMITY_TX_PWR_SERVICE_UUID characteristicUUID:_PROXIMITY_TX_PWR_NOTIFICATION_UUID p:p on:NO];
}




-(void)enableRead:(CBPeripheral*)p
{
    [self notification:ISSC_SERVICE_UUID characteristicUUID:ISSC_CHAR_RX_UUID p:p on:YES];
}

-(void)DisableRead:(CBPeripheral*)p
{
    [self notification:ISSC_SERVICE_UUID characteristicUUID:ISSC_CHAR_RX_UUID p:p on:NO];
}

-(void)enableIAlarm:(CBPeripheral*)p
{
    [self notification:0x1803 characteristicUUID:0x2a06 p:p on:YES];
}

-(void)disableIAlarm:(CBPeripheral*)p
{
    [self notification:0x1803 characteristicUUID:0x2a06 p:p on:NO];
}


-(void)enablePhoto:(CBPeripheral*)p
{
    [self notification:0x4A01 characteristicUUID:0x2A01 p:p on:YES];
}

-(void)disenablePhoto:(CBPeripheral*)p
{
    [self notification:0x4A01 characteristicUUID:0x2A01 p:p on:NO];
}


/***********/
-(void)enbleWriteData:(CBPeripheral*)p
{
    [self notification:0xfff0 characteristicUUID:0xfff6 p:p on:YES];
}
-(void)enbleReadData:(CBPeripheral*)p
{
    [self notification:0xfff0 characteristicUUID:0xfff7 p:p on:YES];
}

/*!
 *  @method writeValue:
 *
 *  @param serviceUUID Service UUID to write to (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to write to (e.g. 0x2401)
 *  @param data Data to write to peripheral
 *  @param p CBPeripheral to write to
 *
 *  @discussion Main routine for writeValue request, writes without feedback. It converts integer into
 *  CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service. 
 *  If this is found, value is written. If not nothing is done.
 *
 */

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
    [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];  //ISSC
}


/*!
 *  @method readValue:
 *
 *  @param serviceUUID Service UUID to read from (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to read from (e.g. 0x2401)
 *  @param p CBPeripheral to read from
 *
 *  @discussion Main routine for read value request. It converts integers into
 *  CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service. 
 *  If this is found, the read value is started. When value is read the didUpdateValueForCharacteristic 
 *  routine is called.
 *
 *  @see didUpdateValueForCharacteristic
 */

-(void)readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p
{
    //NSLog(@"READ:====:%04X, %04X", serviceUUID, characteristicUUID);
    
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
    [p readValueForCharacteristic:characteristic];
}


/*!
 *  @method notification:
 *
 *  @param serviceUUID Service UUID to read from (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to read from (e.g. 0x2401)
 *  @param p CBPeripheral to read from
 *
 *  @discussion Main routine for enabling and disabling notification services. It converts integers 
 *  into CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service. 
 *  If this is found, the notfication is set. 
 *
 */-(void)notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on
{
    //NSLog(@"NOTIFICATION:====:%04X, %04X", serviceUUID, characteristicUUID);
    
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
    [p setNotifyValue:on forCharacteristic:characteristic];
}


/*!
 *  @method swap:
 *
 *  @param s Uint16 value to byteswap
 *
 *  @discussion swap byteswaps a UInt16 
 *
 *  @return Byteswapped UInt16
 */

-(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

/*!
 *  @method controlSetup:
 *
 *  @param s Not used
 *
 *  @return Allways 0 (Success)
 *  
 *  @discussion controlSetup enables CoreBluetooths Central Manager and sets delegate to TIBLECBKeyfob class 
 *
 */
- (int) controlSetup: (int) s{
    self.CM = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    return 0;
}

-(void) setPeripheralManager
{
    self.manager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
}


/*!
 *  @method findBLEPeripherals:
 *
 *  @param timeout timeout in seconds to search for BLE peripherals
 *
 *  @return 0 (Success), -1 (Fault)
 *  
 *  @discussion findBLEPeripherals searches for BLE peripherals and sets a timeout when scanning is stopped
 *
 */
- (int) findBLEPeripherals:(int) timeout
{
   
    NSLog(@"%s",[self centralManagerStateToString:self.CM .state]);
//   [NSTimer scheduledTimerWithTimeInterval:(float)timeout target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
    [self.CM scanForPeripheralsWithServices:nil options:0];
//    [self.delegate setButtonState];
    return 0;
}


/*!
 *  @method connectPeripheral:
 *
 *  @param p Peripheral to connect to
 *
 *  @discussion connectPeripheral connects to a given peripheral and sets the activePeripheral property of TIBLECBKeyfob.
 *
 */
- (void) connectPeripheral:(CBPeripheral *)peripheral {
    //Print("Connecting to peripheral with UUID : %s\r\n",[self UUIDToString:peripheral.UUID]);
    activePeripheral = peripheral;
    activePeripheral.delegate = self;
    [CM connectPeripheral:activePeripheral options:nil];
//    [self.delegate  setButtonState];
}

-(void)disconnect:(CBPeripheral *)peripheral
{
    activePeripheral = peripheral;
    activePeripheral.delegate = self;
    [CM cancelPeripheralConnection:activePeripheral];
    
}
/*!
 *  @method centralManagerStateToString:
 *
 *  @param state State to print info of
 *
 *  @discussion centralManagerStateToString prints information text about a given CBCentralManager state
 *
 */
- (const char *) centralManagerStateToString: (int)state {

    switch(state) {
        case CBCentralManagerStateUnknown: 
            return "State unknown";
        case CBCentralManagerStateResetting:
            return "State resetting";
        case CBCentralManagerStateUnsupported:
            return "State BLE unsupported";
        case CBCentralManagerStateUnauthorized:
            return "State unauthorized";
        case CBCentralManagerStatePoweredOff:

            return "State BLE powered off";

          
        case CBCentralManagerStatePoweredOn:
            return "State powered up and ready";
        default:
            return "State unknown";
    }
    return "Unknown state";

}

/*!
 *  @method scanTimer:
 *
 *  @param timer Backpointer to timer
 *
 *  @discussion scanTimer is called when findBLEPeripherals has timed out, it stops the CentralManager from scanning further and prints out information about known peripherals
 *
 */
- (void) scanTimer:(NSTimer *)timer {
    [self.CM stopScan];
     [self.delegate AddTableView];
//    Print("Stopped Scanning\r\n");
    NSLog(@"find peripherals %d 个",[self.peripherals count]);
//    [self printKnownPeripherals];
      
    if (self->peripherals.count == 0 ) {
        [[self delegate] SetDevice:nil Status:@"No device found!"];
        [self.delegate ScanStop];
        boolBle = 0;
    }
    else
    {
         [self.delegate Stop];
    }
}

/*!
 *  @method printKnownPeripherals:
 *
 *  @discussion printKnownPeripherals prints all curenntly known peripherals stored in the peripherals array of TIBLECBKeyfob class 
 *
 */
- (void) printKnownPeripherals {
/*    int i;
    Print("List of currently known peripherals : \r");
    for (i=0; i < self->peripherals.count; i++)
    {
        CBPeripheral *p = [self->peripherals objectAtIndex:i];
        CFStringRef s = CFUUIDCreateString(NULL, p.UUID);
        Print("%d  |  %s\r\n",i,CFStringGetCStringPtr(s, 0));
        [self printPeripheralInfo:p];
    }
    */
}

/*
 *  @method printPeripheralInfo:
 *
 *  @param peripheral Peripheral to print info of 
 *
 *  @discussion printPeripheralInfo prints detailed info about peripheral 
 *
 */
- (void) printPeripheralInfo:(CBPeripheral*)peripheral
{
/*    CFStringRef s = CFUUIDCreateString(NULL, peripheral.UUID);
    Print("------------------------------------\r");
    Print("Peripheral Info :\r");
    Print("UUID : %s\r",CFStringGetCStringPtr(s, 0));
    Print("RSSI : %d\r",[peripheral.RSSI intValue]);
    Print("Name : %s\r",[peripheral.name cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
    Print("isConnected : %d\r",peripheral.isConnected);
    Print("-------------------------------------\r");
    */
}

/*
 *  @method UUIDSAreEqual:
 *
 *  @param u1 CFUUIDRef 1 to compare
 *  @param u2 CFUUIDRef 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compares two CFUUIDRef's
 *
 */

- (int) UUIDSAreEqual:(CFUUIDRef)u1 u2:(CFUUIDRef)u2 {
    CFUUIDBytes b1 = CFUUIDGetUUIDBytes(u1);
    CFUUIDBytes b2 = CFUUIDGetUUIDBytes(u2);
    if (memcmp(&b1, &b2, 16) == 0) {
        return 1;
    }
    else return 0;
}


/*
 *  @method getAllServicesFromKeyfob
 *
 *  @param p Peripheral to scan
 *
 *
 *  @discussion getAllServicesFromKeyfob starts a service discovery on a peripheral pointed to by p.
 *  When services are found the didDiscoverServices method is called
 *
 */
-(void) getAllServicesFromKeyfob:(CBPeripheral *)p{
    [p discoverServices:nil]; // Discover all services without filter
    
}

/*
 *  @method getAllCharacteristicsFromKeyfob
 *
 *  @param p Peripheral to scan
 *
 *
 *  @discussion getAllCharacteristicsFromKeyfob starts a characteristics discovery on a peripheral
 *  pointed to by p
 *
 */
-(void) getAllCharacteristicsFromKeyfob:(CBPeripheral *)p{
    for (int i=0; i < p.services.count; i++) {
        NSLog(@"servive = %@",[p.services objectAtIndex:i]);
        //过滤不需要的uuid 
     
        CBService *s = [p.services objectAtIndex:i];
        NSString * str = [NSString stringWithFormat:@"%s",[self CBUUIDToString:s.UUID]];
       if([str isEqualToString:@"<fff0>"])
//        NSLog(@"Fetching characteristics for service with UUID : %s\r",[self CBUUIDToString:s.UUID]);
        [p discoverCharacteristics:nil forService:s];
    }
    
    //遍历完所有的才开始连接
//        [self.delegate keyfobReady];
    
}


/*
 *  @method CBUUIDToString
 *
 *  @param UUID UUID to convert to string
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion CBUUIDToString converts the data of a CBUUID class to a character pointer for easy printout using Print()
 *
 */
-(const char *) CBUUIDToString:(CBUUID *) UUID {
    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
}


/*
 *  @method UUIDToString
 *
 *  @param UUID UUID to convert to string
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion UUIDToString converts the data of a CFUUIDRef class to a character pointer for easy printout using Print()
 *
 */
-(const char *) UUIDToString:(CFUUIDRef)UUID {
    if (!UUID) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, UUID);
    return CFStringGetCStringPtr(s, 0);		
    
}

-(char*)ProcessUUIDString:(const char*)uuid_str Result:(char*)str
{
    const char *p = uuid_str;
    int len = strlen(p);
    int i = 0;
    
    for (; i < len; i++) {
        if (p[i] == '<' || p[i] == '>' || p[i] == ' ' || p[i] == '-') {
            continue;
        }
        *str++ = toupper(p[i]);
    }
    
    return str;
}

/*
 *  @method compareCBUUID
 *
 *  @param UUID1 UUID 1 to compare
 *  @param UUID2 UUID 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compareCBUUID compares two CBUUID's to each other and returns 1 if they are equal and 0 if they are not
 *
 */

-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2 {
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1];
    [UUID2.data getBytes:b2];
    int n = memcmp(b1, b2, UUID1.data.length);
    if (n == 0)return 1;
    else return 0;
}

/*
 *  @method compareCBUUIDToInt
 *
 *  @param UUID1 UUID 1 to compare
 *  @param UUID2 UInt16 UUID 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compareCBUUIDToInt compares a CBUUID to a UInt16 representation of a UUID and returns 1 
 *  if they are equal and 0 if they are not
 *
 */
-(int) compareCBUUIDToInt:(CBUUID *)UUID1 UUID2:(UInt16)UUID2 {
    char b1[16];
    [UUID1.data getBytes:b1];
    UInt16 b2 = [self swap:UUID2];
    if (memcmp(b1, (char *)&b2, 2) == 0) return 1;
    else return 0;
}
/*
 *  @method CBUUIDToInt
 *
 *  @param UUID1 UUID 1 to convert
 *
 *  @returns UInt16 representation of the CBUUID
 *
 *  @discussion CBUUIDToInt converts a CBUUID to a Uint16 representation of the UUID
 *
 */
-(UInt16) CBUUIDToInt:(CBUUID *) UUID {
    char b1[16];
    [UUID.data getBytes:b1];
    return ((b1[0] << 8) | b1[1]);
}

/*
 *  @method IntToCBUUID
 *
 *  @param UInt16 representation of a UUID
 *
 *  @return The converted CBUUID
 *
 *  @discussion IntToCBUUID converts a UInt16 UUID to a CBUUID
 *
 */
-(CBUUID *) IntToCBUUID:(UInt16)UUID {
    char t[16];
    t[0] = ((UUID >> 8) & 0xff); t[1] = (UUID & 0xff);
    NSData *data = [[NSData alloc] initWithBytes:t length:16];
    return [CBUUID UUIDWithData:data];
}


/*
 *  @method findServiceFromUUID:
 *
 *  @param UUID CBUUID to find in service list
 *  @param p Peripheral to find service on
 *
 *  @return pointer to CBService if found, nil if not
 *
 *  @discussion findServiceFromUUID searches through the services list of a peripheral to find a 
 *  service with a specific UUID
 *
 */
-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p
{
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
    return nil; //Service not found on this peripheral
}

/*
 *  @method findCharacteristicFromUUID:
 *
 *  @param UUID CBUUID to find in Characteristic list of service
 *  @param service Pointer to CBService to search for charateristics on
 *
 *  @return pointer to CBCharacteristic if found, nil if not
 *
 *  @discussion findCharacteristicFromUUID searches through the characteristic list of a given service 
 *  to find a characteristic with a specific UUID
 *
 */
-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil; //Characteristic not found on this service
}

//----------------------------------------------------------------------------------------------------
//
//CBCentralManagerDelegate protocol methods beneeth here
// Documented in CoreBluetooth documentation
//
//----------------------------------------------------------------------------------------------------

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"Status of CoreBluetooth central manager changed %d (%s)\r\n",central.state,[self centralManagerStateToString:central.state]);
    NSString *status = [NSString stringWithCString:[self centralManagerStateToString:central.state] encoding:NSUTF8StringEncoding];
    [self.delegate SetDevice:self.activePeripheral.name Status:status];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {

    if(!strUUID){
    if (!self.peripherals) {
        peripherals = [[NSMutableArray alloc]init];
        self.arrayRSSI = [[NSMutableArray alloc]init];
    }
    if ([self.peripherals containsObject:peripheral]) {
        NSLog(@"foundPeripherals addObject %@", peripheral.name);
        return;
    }
        [self.peripherals addObject:peripheral];
        [self.arrayRSSI addObject:RSSI];
        [self.delegate Stop];
    }else
    {
         NSString * str = [NSString stringWithFormat:@"%@",peripheral.UUID];
        if([strUUID isEqualToString:[str substringWithRange:NSMakeRange(str.length - 36, 36)]]){
            [self.CM stopScan];
            blePeriphral = peripheral;
           [ self connectPeripheral:peripheral];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    self.activePeripheral = peripheral;
        [self.activePeripheral discoverServices:nil];
//        [self.delegate SetDevice:peripheral.name Status:@"Connected ..."];
}


/*
centralManager:didDisconnectPeripheral:error:
Invoked whenever an existing connection with the peripheral is torn down.
*/
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"error = %@,error's lenght = %d",error,((NSString*)[NSString stringWithFormat:@"%@",error]).length);
    if(((NSString*)[NSString stringWithFormat:@"%@",error]).length>6){
     [self.delegate SetDevice:peripheral.name Status:@"Disconnected!"];
     [self.delegate Disconnected];
    }
    else
    {
       [self.delegate WellDisconnected];
    }
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self.delegate SetDevice:peripheral.name Status:@"Fail To Connect Peripheral!"];
}

-(void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    NSLog(@"-------------------------------");
    NSLog(@"didRetrieveConnectedPeripherals");
    
//    [self.activePeripheral ca
    
    //NSLog(@"COUNT:%d", [self.peripherals count]);
    
    //[CM retrievePeripherals:self.peripherals];
}


-(void)retrieveConnect:(CBUUID*)uuid
{
    if (uuid == nil) {
        return;
    }
    
    for(int i = 0; i < self.peripherals.count; i++) {
        CBPeripheral *p = [self.peripherals objectAtIndex:i];
        
        if (p.UUID == nil) {
            continue;
        }
        
        const char *cu1 = [self UUIDToString:p.UUID];
        const char *cu2 = [self CBUUIDToString:uuid];
        char u1[64] = {'\0'};
        char u2[64] = {'\0'};
        [self ProcessUUIDString:cu1 Result:u1];
        [self ProcessUUIDString:cu2 Result:u2];
        
        if (strcmp(u1, u2) == 0) {
            b_restrieve = YES;
            [CM connectPeripheral:p options:nil];
            return;
        }
    }
}

//----------------------------------------------------------------------------------------------------
//
//
//
//
//
//CBPeripheralDelegate protocol methods beneeth here
//
//
//
//
//
//----------------------------------------------------------------------------------------------------


/*
 *  @method didDiscoverCharacteristicsForService
 *
 *  @param peripheral Pheripheral that got updated
 *  @param service Service that characteristics where found on
 *  @error error Error message if something went wrong
 *
 *  @discussion didDiscoverCharacteristicsForService is called when CoreBluetooth has discovered 
 *  characteristics on a service, on a peripheral after the discoverCharacteristics routine has been called on the service
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSString * str = [NSString stringWithFormat:@"%@",peripheral.UUID];
    [[self delegate] BindWithUUID:[str substringWithRange:NSMakeRange(str.length - 36, 36)]];
   [[self delegate] keyfobReady];
    if (!error) {
        
    }
    else {
        NSLog(@"Characteristic discorvery unsuccessfull !\r\n");
        [self.delegate SetDevice:nil Status:@"Characteristic discorvery unsuccessfull!"];
        [self.delegate Stop];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
}

/*
 *  @method didDiscoverServices
 *
 *  @param peripheral Pheripheral that got updated
 *  @error error Error message if something went wrong
 *
 *  @discussion didDiscoverServices is called when CoreBluetooth has discovered services on a 
 *  peripheral after the discoverServices routine has been called on the peripheral
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        //Print("Services of peripheral with UUID : %s found\r\n",[self UUIDToString:peripheral.UUID]);
        [self getAllCharacteristicsFromKeyfob:peripheral];
    }
    else {
        NSLog(@"Service discovery was unsuccessfull !\r\n");
        NSLog(@"%s", [error.description UTF8String]);
        [self.delegate SetDevice:nil Status:@"Service discovery was unsuccessfull!"];
        [self.delegate Stop];
    }
}

/*
 *  @method didUpdateNotificationStateForCharacteristic
 *
 *  @param peripheral Pheripheral that got updated
 *  @param characteristic Characteristic that got updated
 *  @error error Error message if something went wrong
 *
 *  @discussion didUpdateNotificationStateForCharacteristic is called when CoreBluetooth has updated a 
 *  notification state for a characteristic
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    if (!error) {
//        NSLog(@"Updated notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[self UUIDToString:peripheral.UUID]);
//    }
//    else {
//        NSLog(@"Error in setting notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[self UUIDToString:peripheral.UUID]);
//        NSLog(@"Error code was %s\r\n",[[error description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
//    }
    
}

/*
 *  @method didUpdateValueForCharacteristic
 *
 *  @param peripheral Pheripheral that got updated
 *  @param characteristic Characteristic that got updated
 *  @error error Error message if something went wrong
 *
 *  @discussion didUpdateValueForCharacteristic is called when CoreBluetooth has updated a 
 *  characteristic for a peripheral. All reads and notifications come here to be processed.
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    UInt16 characteristicUUID = [self CBUUIDToInt:characteristic.UUID];
    
    if (!error) {
        switch(characteristicUUID) 
        {
            case _LEVEL_SERVICE_UUID:
            {
                char batlevel;
                [characteristic.value getBytes:&batlevel length:_LEVEL_SERVICE_READ_LEN];
                self.batteryLevel = (float)batlevel;
                [self.delegate ShowPercent:self.batteryLevel];
                break;
            }
            case 0x1803:
            {
                unsigned char keys[2048] = {0};
                [characteristic.value getBytes:keys];
                [self.delegate DisplayRece:keys length:[characteristic.value length]];
                self.key1 = (keys[0] & 0x01);
                self.key2 = (keys[0] & 0x02);
                [[self delegate] keyValuesUpdated: keys[0]];
                //[self.delegate keyfobReady];
            }
            case _ACCEL_X_UUID:
            {
                char xval; 
                [characteristic.value getBytes:&xval length:_ACCEL_READ_LEN];
                self.x = xval;
                [[self delegate] accelerometerValuesUpdated:self.x y:self.y z:self.z];
                break;
            }
            case _ACCEL_Y_UUID:
            {
                char yval; 
                [characteristic.value getBytes:&yval length:_ACCEL_READ_LEN];
                self.y = yval;
                [[self delegate] accelerometerValuesUpdated:self.x y:self.y z:self.z];
                break;
            }
            case _ACCEL_Z_UUID:
            {
                char zval; 
                [characteristic.value getBytes:&zval length:_ACCEL_READ_LEN];
                self.z = zval;
                [[self delegate] accelerometerValuesUpdated:self.x y:self.y z:self.z];
                break;
            }
            case _PROXIMITY_TX_PWR_NOTIFICATION_UUID:
            {
                char TXLevel;
                [characteristic.value getBytes:&TXLevel length:_PROXIMITY_TX_PWR_NOTIFICATION_READ_LEN];
                self.TXPwrLevel = TXLevel;
                [[self delegate] TXPwrLevelUpdated:TXLevel];
            }
            case ISSC_CHAR_RX_UUID:
            {
                unsigned char buf[4096] = {0}; 
                [characteristic.value getBytes:buf];
               [self.delegate DisplayRece:buf length:[characteristic.value length]];
                break;
            }
            default:
            {
                unsigned char buf[4096] = {0};
                [characteristic.value getBytes:buf];
                [self.delegate DisplayRece:buf length:[characteristic.value length]];
                break;
            }
        }
    }
    else {
        NSLog(@"updateValueForCharacteristic failed !");
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}




//  CBPeripheralManagerDelegate
/*!
 *  @method peripheralManagerDidUpdateState:
 *
 *  @param peripheral   The peripheral manager whose state has changed.
 *
 *  @discussion         Invoked whenever the peripheral manager's state has been updated. Commands should only be issued when the state is
 *                      <code>CBPeripheralManagerStatePoweredOn</code>. A state below <code>CBPeripheralManagerStatePoweredOn</code>
 *                      implies that advertisement has stopped and any connected centrals have been disconnected. If the state moves below
 *                      <code>CBPeripheralManagerStatePoweredOff</code>, advertisement is stopped and must be explicitly restarted, and the
 *                      local database is cleared and all services must be re-added.
 *
 *  @see                state
 *
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
  {
      NSLog(@"Done2222");
      switch (peripheral.state) {
          case CBPeripheralManagerStatePoweredOn:{
              
              CBUUID *cUDID = [CBUUID UUIDWithString:@"0x2A11"];
              //            CBUUID *cUDID1 = [CBUUID UUIDWithString:@"DA17"];
              //            CBUUID *cUDID2 = [CBUUID UUIDWithString:@"DA16"];
              
              CBUUID *sUDID = [CBUUID UUIDWithString:@"0x4A01"];
           CBMutableCharacteristic*   characteristic = [[CBMutableCharacteristic alloc]initWithType:cUDID properties:CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsWriteable];
             // NSLog(@"%u",characteristic2.properties);
              servicea = [[CBMutableService alloc]initWithType:sUDID primary:YES];
              //            servicea.characteristics = @[characteristic,characteristic1,characteristic2];
              servicea.characteristics =@[characteristic];
              [peripheral addService:servicea];
          }
              break;
              
          default:
              NSLog(@"%i",peripheral.state);
              break;
      }

  }

/*!
 *  @method peripheralManagerDidStartAdvertising:error:
 *
 *  @param peripheral   The peripheral manager providing this information.
 *  @param error        If an error occurred, the cause of the failure.
 *
 *  @discussion         This method returns the result of a @link startAdvertising: @/link call. If advertisement could
 *                      not be started, the cause will be detailed in the <i>error</i> parameter.
 *
 */



- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    
    
}

/*!
 *  @method peripheralManager:didAddService:error:
 *
 *  @param peripheral   The peripheral manager providing this information.
 *  @param service      The service that was added to the local database.
 *  @param error        If an error occurred, the cause of the failure.
 *
 *  @discussion         This method returns the result of an @link addService: @/link call. If the service could
 *                      not be published to the local database, the cause will be detailed in the <i>error</i> parameter.
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
//    NSDictionary *advertisingData = @{CBAdvertisementDataLocalNameKey : @"KhaosT", CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:@"3DA3951B-F780-E158-80A1-BD12249E2C17"]]};
//    
//    [peripheral startAdvertising:advertisingData];
}

/*!
 *  @method peripheralManager:central:didSubscribeToCharacteristic:
 *
 *  @param peripheral       The peripheral manager providing this update.
 *  @param central          The central that issued the command.
 *  @param characteristic   The characteristic on which notifications or indications were enabled.
 *
 *  @discussion             This method is invoked when a central configures <i>characteristic</i> to notify or indicate.
 *                          It should be used as a cue to start sending updates as the characteristic value changes.
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    
}

/*!
 *  @method peripheralManager:central:didUnsubscribeFromCharacteristic:
 *
 *  @param peripheral       The peripheral manager providing this update.
 *  @param central          The central that issued the command.
 *  @param characteristic   The characteristic on which notifications or indications were disabled.
 *
 *  @discussion             This method is invoked when a central removes notifications/indications from <i>characteristic</i>.
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    
}

/*!
 *  @method peripheralManager:didReceiveReadRequest:
 *
 *  @param peripheral   The peripheral manager requesting this information.
 *  @param request      A <code>CBATTRequest</code> object.
 *
 *  @discussion         This method is invoked when <i>peripheral</i> receives an ATT request for a characteristic with a dynamic value.
 *                      For every invocation of this method, @link respondToRequest:withResult: @/link must be called.
 *
 *  @see                CBATTRequest
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests{
    for (CBATTRequest *aReq in requests){
        [self.delegate startPhoto];
    }
}
/*!
 *  @method peripheralManager:didReceiveWriteRequests:
 *
 *  @param peripheral   The peripheral manager requesting this information.
 *  @param requests     A list of one or more <code>CBATTRequest</code> objects.
 *
 *  @discussion         This method is invoked when <i>peripheral</i> receives an ATT request or command for one or more characteristics with a dynamic value.
 *                      For every invocation of this method, @link respondToRequest:withResult: @/link should be called exactly once. If <i>requests</i> contains
 *                      multiple requests, they must be treated as an atomic unit. If the execution of one of the requests would cause a failure, the request
 *                      and error reason should be provided to <code>respondToRequest:withResult:</code> and none of the requests should be executed.
 *
 *  @see                CBATTRequest
 *
 */


/*!
 *  @method peripheralManagerIsReadyToUpdateSubscribers:
 *
 *  @param peripheral   The peripheral manager providing this update.
 *
 *  @discussion         This method is invoked after a failed call to @link updateValue:forCharacteristic:onSubscribedCentrals: @/link, when <i>peripheral</i> is again
 *                      ready to send characteristic value updates.
 *
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    
}


@end
