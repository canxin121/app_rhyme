# AppRhyme
## 果韵
使用Flutter和Rust开发的跨平台`自定义音源`音乐播放器 

后端Rust库仓库[music_api](https://github.com/canxin121/music_api).

### 支持的音乐平台:
- 网易云音乐
- 酷我音乐

### 开发维护优先级
1. Linux Android Ios
2. Windows 
3. Macos

### 安装说明
1. linux依赖:  
须自行安装：libmpv-dev mpv  
例如使用apt:
```bash
sudo apt install libmpv-dev mpv
```

### 功能:
- 移动设备视图
- 卓面设备视图
- 自适应黑夜模式
- 应用本体更新检测
- 导入音源链接并自动检测更新
- 音乐播放和缓存(由用户自定义音源提供音乐数据)
- 音乐自动换源播放
- 应用音量调节
- 应用内歌词显示，待播清单
- 音乐、歌单搜索, 专辑查看
- 通过链接导入歌单
- 自定义数据存储目录
- wifi/数据下音质选择
### 演示

https://github.com/canxin121/app_rhyme/assets/69547456/a1b331ed-6e98-4ace-befc-3543981c6312  

https://github.com/user-attachments/assets/1664464e-02ea-49b3-ae17-c539ccf3154e  

------
## 说明
本协议中的“本项目”指AppRhyme项目；“使用者”指签署本协议的使用者；“官方音乐平台”指对本项目内置的包括酷我、酷狗、咪咕等音乐源的官方平台统称；“版权数据”指包括但不限于图像、音频、名字等在内的他人拥有所属版权的数据。

### 注意

本项目无力提供音乐播放链接或音频文件，只具备从各官方音乐平台的官方公开数据库中检索和提供音乐的基本信息和自定义歌单存储的功能。
如需音乐播放和缓存功能，请自行制作和使用音源链接自己的音乐库，用户的第三方音源内容与本项目无关，本项目无法提供相关支持。

### 数据源

本项目的所有官方音乐数据均从各官方音乐平台的公开数据库中获取，所获得数据和未登录状态下各官方平台数据相同，仅对数据做简单处理和抽象综合，因此本项目无力为数据的合法性和正确性负责。

本项目的非官方数据(如储存的歌单等)来自使用者的设备的本地储存或其他类型的文件系统或由使用者资质自己的音源提供，因此本项目无力为数据的合法性和正确性负责。

### 版权

本项目代码运行中可能会产生版权数据，数据所有权归各官方平台所有。**为避免侵权，请使用者务必在24小时内清除本项目的版权数据**；
**音乐创作不易，请保护版权，支持正版。**

### 网络资源与ui资源

本项目所使用的其他类型资源(包括不限于图片，图标等)均来自互联网，如果侵权可以联系我进行删除。

本项目所使用ui来自flutter官方ui库和pub.dev,github上的第三方ui库。

### 免责声明

由于使用本项目产生的包括由于使用本项目而引起的任何性质的任何直接、间接、特殊、偶然或结果性损害（包括但不限于因商誉损失、停工、计算机故障或故障引起的损害赔偿，或任何及所有其他商业损害或损失等）由使用者负责。

### 使用限制
1. 本软件完全开源和免费，不会向使用者收取任何形式的费用。
2. 使用本项目代码的使用者必须接受本项目的协议和免责声明。
3. 务必在当地法律的允许范围内使用本项目，由于Github和音乐的全球性，本项目无法保证符合世界各国各地区法律规定。对于违法当地法律的使用者，造成的一切违法违规由使用者自行承担责任，本项目不承担由此造成的任何直接、间接、特殊、偶然或结果性责任。

### 贡献声明

本项目不接受任何商业合作，不接受任何商业捐赠。
本项目欢迎开源代码贡献和ui设计贡献，但请贡献内容符合法律法规和协议要求。

# Star 历史

<a href="https://star-history.com/#canxin121/app_rhyme&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=canxin121/app_rhyme&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=canxin121/app_rhyme&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=canxin121/app_rhyme&type=Date" />
 </picture>
</a>


# 协议

MIT or Apache-2.0
