#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 1. Инициализируем главное окно приложения на весь физический экран устройства
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // 2. Создаем экземпляр нашего главного контроллера (ViewController)
    ViewController *mainViewController = [[ViewController alloc] init];
    
    // 3. Назначаем его корневым (root) контроллером для окна
    self.window.rootViewController = mainViewController;
    
    // 4. Делаем окно активным и видимым на экране
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {}
- (void)applicationDidEnterBackground:(UIApplication *)application {}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationDidBecomeActive:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}

@end
