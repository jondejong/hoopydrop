//
//  HelpLayer.m
//  HoopyDrop
//
//  Created by Jon DeJong on 9/19/12.
//
//

#import "HoopyDrop.h"

@implementation HelpLayer{
    @private
    int _page;
    int _lastPage;
    bool _moving;
}

- (id)init
{
    self = [super init];
    if (self) {
        _moving = NO;
        _page = 1;
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCSprite* banner = [CCSprite spriteWithFile:@"help_banner.png"];
//        banner.anchorPoint = ccp(banner.anchorPoint.x, 0
        
        banner.position = ccp(size.width/2, (size.height - HELP_TOP_OFFSET)/2 + HELP_TOP_OFFSET);
        
        [self addChild:banner z:OBJECTS_Z];
        
        CCSprite* helpPage1Sprite = [CCSprite spriteWithFile:@"help_page_1.png"];
        helpPage1Sprite.anchorPoint = ccp(0, 0);
        helpPage1Sprite.position = ccp(0, HELP_SCREEN_Y_POINTS);
        
        [self addChild:[BackgroundLayer node] z:BACKGROUND_Z];
        [self addChild:helpPage1Sprite z:OBJECTS_Z tag:kHelpPage1Tag];
        
        [self createMenuWithBackward:NO andForward:YES];
    }
    return self;
}

-(void) createMenuWithBackward: (bool) backward andForward: (bool) forward
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    CCMenuItemFont* goBackMenuItem = [CCMenuItemFont itemWithString:@"Go Home" target:self selector:@selector(handleGoBack)];
    
    [goBackMenuItem setFontSize:20];
    [goBackMenuItem setFontName:@"Marker Felt"];
    
    CCMenu* resetMenu;
   
    if(backward && forward) {
        resetMenu = [CCMenu menuWithItems:[self createBackButton], goBackMenuItem, [self createForwardButton], nil];
        resetMenu.position = ccp(size.width/2, 50);
    } else if(backward) {
        resetMenu = [CCMenu menuWithItems:[self createBackButton], goBackMenuItem, nil];
        resetMenu.position = ccp(size.width/2 - HELP_SCREEN_MENU_OFFSET, 50);
    } else {
        resetMenu = [CCMenu menuWithItems:goBackMenuItem, [self createForwardButton], nil];
        resetMenu.position = ccp(size.width/2 + HELP_SCREEN_MENU_OFFSET, 50);
    }
    
    [resetMenu alignItemsHorizontallyWithPadding:20];
    [self addChild:resetMenu z:OBJECTS_Z tag:kHelpMenuTag];
}

-(CCMenuItemSprite*) createForwardButton
{
    CCSprite * forwardButtonSprite = [CCSprite spriteWithFile:@"forward.png"];
    CCSprite * forwardButtonSelectedSprite = [CCSprite spriteWithFile:@"forward.png"];
    
    CCMenuItemSprite* forwardButton = [CCMenuItemSprite itemWithNormalSprite:forwardButtonSprite selectedSprite:forwardButtonSelectedSprite target:self selector:@selector(handleForwardButtonPress)];
    return forwardButton;
}

-(CCMenuItemSprite*) createBackButton
{
    CCSprite * backwardButtonSprite = [CCSprite spriteWithFile:@"backward.png"];
    CCSprite * backwardButtonSelectedSprite = [CCSprite spriteWithFile:@"backward.png"];
    
    CCMenuItemSprite* backwardButton = [CCMenuItemSprite itemWithNormalSprite:backwardButtonSprite selectedSprite:backwardButtonSelectedSprite target:self selector:@selector(handleBackwardButtonPress)];
    
    return backwardButton;
    
}

-(void) handleForwardButtonPress
{
    if(_moving) {
        return;
    }
    _moving = YES;
    _lastPage = [self getPageTag];
    
    CGPoint pos = ccp(-320, HELP_SCREEN_Y_POINTS);
    CCNode* howToSprite = [self getChildByTag:_lastPage];
    CCFiniteTimeAction* moveAction = [CCMoveTo actionWithDuration: HELP_SCREEN_MOVE_SECONDS position: pos];
    
    CCCallFunc* doneHandler = [CCCallFunc actionWithTarget:self selector:@selector(removeLastPage)];
    
    _page++;
    NSString* newPageSpriteName = [NSString stringWithFormat:@"help_page_%i.png", _page];
    int nextPageTag = [self getPageTag];
    CCSprite* newPageSprite = [CCSprite spriteWithFile:newPageSpriteName];
    
    newPageSprite.position = ccp(320, HELP_SCREEN_Y_POINTS);
    newPageSprite.anchorPoint = ccp(0,0);
    [self addChild:newPageSprite z:OBJECTS_Z tag:nextPageTag];
    CCFiniteTimeAction* newPageMoveAction = [CCMoveTo actionWithDuration: HELP_SCREEN_MOVE_SECONDS position: ccp(0 ,HELP_SCREEN_Y_POINTS)];
    
    [howToSprite runAction:[CCSequence actions:moveAction, doneHandler, nil]];
    [newPageSprite runAction:[CCSequence actions:newPageMoveAction, nil]];
    
    [self resetMenu];
    
}

-(void) handleBackwardButtonPress
{
    if(_moving) {
        return;
    }
    _moving = YES;
    _lastPage = [self getPageTag];
    
    CGPoint pos = ccp(320, HELP_SCREEN_Y_POINTS);
    CCNode* howToSprite = [self getChildByTag:_lastPage];
    CCFiniteTimeAction* moveAction = [CCMoveTo actionWithDuration: HELP_SCREEN_MOVE_SECONDS position: pos];
    
    CCCallFunc* doneHandler = [CCCallFunc actionWithTarget:self selector:@selector(removeLastPage)];
    
    _page--;
    NSString* newPageSpriteName = [NSString stringWithFormat:@"help_page_%i.png", _page];
    int nextPageTag = [self getPageTag];
    CCSprite* newPageSprite = [CCSprite spriteWithFile:newPageSpriteName];
    
    newPageSprite.position = ccp(-320, HELP_SCREEN_Y_POINTS);
    newPageSprite.anchorPoint = ccp(0,0);
    [self addChild:newPageSprite z:OBJECTS_Z tag:nextPageTag];
    CCFiniteTimeAction* newPageMoveAction = [CCMoveTo actionWithDuration: HELP_SCREEN_MOVE_SECONDS position: ccp(0 ,HELP_SCREEN_Y_POINTS)];
    
    [howToSprite runAction:[CCSequence actions:moveAction, doneHandler, nil]];
    [newPageSprite runAction:[CCSequence actions:newPageMoveAction, nil]];
    [self resetMenu];
    
}

-(void) removeLastPage
{
    _moving = NO;
    [self removeChildByTag:_lastPage cleanup:YES];
}

-(void) resetMenu
{
    [self removeChildByTag:kHelpMenuTag cleanup:YES];
    if(_page == HELP_SCREEN_PAGE_COUNT) {
        [self createMenuWithBackward:YES andForward:NO];
    } else if(_page==1){
        [self createMenuWithBackward:NO andForward:YES];
    } else {
        [self createMenuWithBackward:YES andForward:YES];
    }
}

-(int) getPageTag {
    int pageTag = 0;
    switch (_page) {
        case 1:
            pageTag = kHelpPage1Tag;
            break;
            
        case 2:
            pageTag = kHelpPage2Tag;
            break;
            
        case 3:
            pageTag = kHelpPage3Tag;
            break;
            
        default:
            break;
    }
    return pageTag;
}


-(void) handleGoBack {
    [[CCDirector sharedDirector] popScene];
}

@end
