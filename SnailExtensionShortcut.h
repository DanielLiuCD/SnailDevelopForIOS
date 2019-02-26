//
//  SnailExtensionShortcut.m
//  QianXun
//
//  Created by JobNewMac1 on 2018/11/15.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

/*-----------------------------------------------MJRefesh------------------------------------------------*/

#define SNA_MJREFESH_END(SCRO) if (SCRO.mj_header.state == MJRefreshStateRefreshing) { \
[SCRO.mj_header endRefreshing];\
}\
if (SCRO.mj_footer.state == MJRefreshStateRefreshing) {\
[SCRO.mj_footer endRefreshing];\
}\
