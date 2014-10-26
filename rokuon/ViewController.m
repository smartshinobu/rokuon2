//
//  ViewController.m
//  rokuon
//
//  Created by ビザンコムマック０７ on 2014/10/24.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@end

@implementation ViewController{
    AVAudioRecorder *avRecorder;
    AVAudioSession *audioSession;
    AVAudioPlayer *avPlayer;
    BOOL rokuonStarting;
}
- (void)viewDidLoad {
    rokuonStarting = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//録音または録音ストップと書かれたボタンを押すと呼ばれるメソッド
- (IBAction)rokuon:(id)sender {
    //録音状態でないかどうか
    if (rokuonStarting == NO) {
    audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    NSError *error = nil;
    // 使用している機種が録音に対応しているか
    if ([audioSession inputIsAvailable]) {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    }
    if(error){
        NSLog(@"audioSession: %@ %ld %@", [error domain], [error code], [[error userInfo] description]);
    }
    // 録音機能をアクティブにする
    [audioSession setActive:YES error:&error];
    if(error){
        NSLog(@"audioSession: %@ %ld %@", [error domain], [error code], [[error userInfo] description]);
    }
        NSDictionary *dic;
        //AVEncoderAudioQualityKey オーディオ品質を設定するキー?
        //AVEncoderBitRateKey オーディオビットレートを設定するキー?
        //AVSampleRateKey 周波数(ヘルツ)を設定するキー?(このキーの値が小さいほどデータのサイズは小さくなる?)
        //AVNumberOfChannelsKey　チャネルの数を設定するキー?
        dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:AVAudioQualityLow],AVEncoderAudioQualityKey,
               [NSNumber numberWithInt:16],
               AVEncoderBitRateKey,
               [NSNumber numberWithInt: 1],
               AVNumberOfChannelsKey,
               [NSNumber numberWithFloat:1000.0],
               AVSampleRateKey,
               nil];
    // 録音ファイルパス
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,YES);
    NSString *documentDir = [filePaths objectAtIndex:0];
        //wavファイルとして保存する
    NSString *path = [documentDir stringByAppendingPathComponent:@"rec.caf"];
    NSURL *recordingURL = [NSURL fileURLWithPath:path];
    avRecorder = [[AVAudioRecorder alloc] initWithURL:recordingURL settings:dic error:&error];
    
    if(error){
        NSLog(@"patherror = %@",error);
        return;
    }
        //録音開始
        [avRecorder prepareToRecord];
    [avRecorder record];
    rokuonStarting = YES;
        //ボタンのタイトルを録音ストップとする
        [self.btn setTitle:@"録音ストップ" forState:UIControlStateNormal];
    }
    //録音状態であるかどうか
    else if(rokuonStarting == YES){
        //録音をやめる
    [avRecorder stop];
    rokuonStarting = NO;
        //ボタンのタイトルを録音ストップとする
        [self.btn setTitle:@"録音" forState:UIControlStateNormal];
        NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                 NSUserDomainMask,YES);
        NSString *documentDir = [filePaths objectAtIndex:0];
        NSString *path = [documentDir stringByAppendingPathComponent:@"rec.caf"];
        //パスからデータを取得
        NSData *musicdata = [[NSData alloc]initWithContentsOfFile:path];
        //ファイルをサーバーにアップするためのプログラムのURLを生成
        NSURL *url = [NSURL URLWithString:@"http://bizanshinobu.miraiserver.com/file.php"];
        //urlをもとにしたリクエストを生成
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        //リクエストメッセージのbody部分を作るための変数
        NSMutableData *body = [NSMutableData data];
        //バウンダリ文字列(仕切線)を格納している変数
        NSString *boundary = @"---------------------------168072824752491622650073";
        //Content-typeヘッダに設定する情報を格納する変数
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        //POST形式の通信を行うようにする
        [request setHTTPMethod:@"POST"];
        //bodyの最初にバウンダリ文字列(仕切線)を追加
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        //サーバー側に送るファイルの項目名をsample
        //送るファイル名をexample.cafと設定
        [body appendData:[@"Content-Disposition: form-data; name=\"sample\"; filename=\"example.caf\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        //送るファイルのデータのタイプを設定する情報を追加
        [body appendData:[@"Content-Type: audio/x-caf\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        //音楽ファイルのデータを追加
        [body appendData:musicdata];
        NSLog(@"録音のデータサイズ%ldバイト",musicdata.length);
        //最後にバウンダリ文字列を追加
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        //ヘッダContent-typeに情報を追加
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        //リクエストのボディ部分に変数bodyをセット
        [request setHTTPBody:body];
        NSURLResponse *response;
        NSError *err = nil;
        //サーバーとの通信を行う
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
        //サーバーからのデータを文字列に変換
        NSString *datastring = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",datastring);

    }

}

//再生ボタンを押すと呼ばれるメソッド
- (IBAction)saisei:(id)sender {
    audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    // 録音ファイルパス
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,YES);
    NSString *documentDir = [filePaths objectAtIndex:0];
    //rec.wavファイルがあるパスの文字列を格納
    NSString *path = [documentDir stringByAppendingPathComponent:@"rec.caf"];
    NSURL *recordingURL = [NSURL fileURLWithPath:path];
    
    avPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:recordingURL error:nil];
    avPlayer.volume=1.0;
    //再生
    [avPlayer play];
}
@end
