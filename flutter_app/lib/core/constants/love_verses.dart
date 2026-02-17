/// 爱情主题诗词库：古典 + 现代，用于首页、登录、空状态等随机展示，每次进入皆有惊喜。
/// 古典为公版名句；现代为常见引用句，注明作者。

class LoveVerse {
  final String text;
  final String source;

  const LoveVerse({required this.text, required this.source});
}

/// 内置大量关于爱情的古诗词名句
class LoveVerses {
  LoveVerses._();

  static const List<LoveVerse> all = [
    // 诗经
    LoveVerse(text: '所谓伊人，在水一方。', source: '《诗经·秦风·蒹葭》'),
    LoveVerse(text: '青青子衿，悠悠我心。', source: '《诗经·郑风·子衿》'),
    LoveVerse(text: '今夕何夕，见此良人。', source: '《诗经·唐风·绸缪》'),
    LoveVerse(text: '执子之手，与子偕老。', source: '《诗经·邶风·击鼓》'),
    LoveVerse(text: '一日不见，如三秋兮。', source: '《诗经·王风·采葛》'),
    LoveVerse(text: '琴瑟在御，莫不静好。', source: '《诗经·郑风·女曰鸡鸣》'),
    LoveVerse(text: '心乎爱矣，遐不谓矣。', source: '《诗经·小雅·隰桑》'),
    LoveVerse(text: '窈窕淑女，君子好逑。', source: '《诗经·周南·关雎》'),
    LoveVerse(text: '投我以木桃，报之以琼瑶。', source: '《诗经·卫风·木瓜》'),
    LoveVerse(text: '死生契阔，与子成说。', source: '《诗经·邶风·击鼓》'),
    LoveVerse(text: '既见君子，云胡不喜。', source: '《诗经·郑风·风雨》'),
    LoveVerse(text: '宜言饮酒，与子偕老。', source: '《诗经·郑风·女曰鸡鸣》'),
    LoveVerse(text: '未见君子，忧心忡忡。', source: '《诗经·召南·草虫》'),
    LoveVerse(text: '有美一人，清扬婉兮。', source: '《诗经·郑风·野有蔓草》'),
    LoveVerse(text: '邂逅相遇，与子偕臧。', source: '《诗经·郑风·野有蔓草》'),
    // 汉魏乐府与古诗
    LoveVerse(text: '山无陵，江水为竭，冬雷震震夏雨雪，天地合，乃敢与君绝。', source: '汉乐府《上邪》'),
    LoveVerse(text: '愿得一心人，白头不相离。', source: '卓文君《白头吟》'),
    LoveVerse(text: '思君令人老，岁月忽已晚。', source: '《古诗十九首·行行重行行》'),
    LoveVerse(text: '同心而离居，忧伤以终老。', source: '《古诗十九首·涉江采芙蓉》'),
    LoveVerse(text: '盈盈一水间，脉脉不得语。', source: '《古诗十九首·迢迢牵牛星》'),
    LoveVerse(text: '结发为夫妻，恩爱两不疑。', source: '苏武《留别妻》'),
    LoveVerse(text: '生当复来归，死当长相思。', source: '苏武《留别妻》'),
    // 唐诗
    LoveVerse(text: '在天愿作比翼鸟，在地愿为连理枝。', source: '白居易《长恨歌》'),
    LoveVerse(text: '天长地久有时尽，此恨绵绵无绝期。', source: '白居易《长恨歌》'),
    LoveVerse(text: '曾经沧海难为水，除却巫山不是云。', source: '元稹《离思》'),
    LoveVerse(text: '取次花丛懒回顾，半缘修道半缘君。', source: '元稹《离思》'),
    LoveVerse(text: '春蚕到死丝方尽，蜡炬成灰泪始干。', source: '李商隐《无题》'),
    LoveVerse(text: '身无彩凤双飞翼，心有灵犀一点通。', source: '李商隐《无题》'),
    LoveVerse(text: '此情可待成追忆，只是当时已惘然。', source: '李商隐《锦瑟》'),
    LoveVerse(text: '何当共剪西窗烛，却话巴山夜雨时。', source: '李商隐《夜雨寄北》'),
    LoveVerse(text: '美人如花隔云端。', source: '李白《长相思》'),
    LoveVerse(text: '长相思，摧心肝。', source: '李白《长相思》'),
    LoveVerse(text: '春风不相识，何事入罗帏。', source: '李白《春思》'),
    LoveVerse(text: '当君怀归日，是妾断肠时。', source: '李白《春思》'),
    LoveVerse(text: '红豆生南国，春来发几枝。愿君多采撷，此物最相思。', source: '王维《相思》'),
    LoveVerse(text: '闺中少妇不知愁，春日凝妆上翠楼。', source: '王昌龄《闺怨》'),
    LoveVerse(text: '忽见陌头杨柳色，悔教夫婿觅封侯。', source: '王昌龄《闺怨》'),
    LoveVerse(text: '还君明珠双泪垂，恨不相逢未嫁时。', source: '张籍《节妇吟》'),
    LoveVerse(text: '东边日出西边雨，道是无晴却有晴。', source: '刘禹锡《竹枝词》'),
    LoveVerse(text: '人面不知何处去，桃花依旧笑春风。', source: '崔护《题都城南庄》'),
    LoveVerse(text: '去年今日此门中，人面桃花相映红。', source: '崔护《题都城南庄》'),
    LoveVerse(text: '至高至明日月，至亲至疏夫妻。', source: '李冶《八至》'),
    // 宋词
    LoveVerse(text: '两情若是久长时，又岂在朝朝暮暮。', source: '秦观《鹊桥仙》'),
    LoveVerse(text: '金风玉露一相逢，便胜却人间无数。', source: '秦观《鹊桥仙》'),
    LoveVerse(text: '只愿君心似我心，定不负相思意。', source: '李之仪《卜算子》'),
    LoveVerse(text: '日日思君不见君，共饮长江水。', source: '李之仪《卜算子》'),
    LoveVerse(text: '衣带渐宽终不悔，为伊消得人憔悴。', source: '柳永《蝶恋花》'),
    LoveVerse(text: '十年生死两茫茫，不思量，自难忘。', source: '苏轼《江城子》'),
    LoveVerse(text: '相顾无言，惟有泪千行。', source: '苏轼《江城子》'),
    LoveVerse(text: '夜来幽梦忽还乡，小轩窗，正梳妆。', source: '苏轼《江城子》'),
    LoveVerse(text: '此心安处是吾乡。', source: '苏轼《定风波》'),
    LoveVerse(text: '花自飘零水自流，一种相思，两处闲愁。', source: '李清照《一剪梅》'),
    LoveVerse(text: '此情无计可消除，才下眉头，却上心头。', source: '李清照《一剪梅》'),
    LoveVerse(text: '云中谁寄锦书来，雁字回时，月满西楼。', source: '李清照《一剪梅》'),
    LoveVerse(text: '寻寻觅觅，冷冷清清，凄凄惨惨戚戚。', source: '李清照《声声慢》'),
    LoveVerse(text: '莫道不销魂，帘卷西风，人比黄花瘦。', source: '李清照《醉花阴》'),
    LoveVerse(text: '众里寻他千百度，蓦然回首，那人却在灯火阑珊处。', source: '辛弃疾《青玉案》'),
    LoveVerse(text: '若教眼底无离恨，不信人间有白头。', source: '辛弃疾《鹧鸪天》'),
    LoveVerse(text: '从别后，忆相逢，几回魂梦与君同。', source: '晏几道《鹧鸪天》'),
    LoveVerse(text: '今宵剩把银釭照，犹恐相逢是梦中。', source: '晏几道《鹧鸪天》'),
    LoveVerse(text: '天涯地角有穷时，只有相思无尽处。', source: '晏殊《玉楼春》'),
    LoveVerse(text: '无情不似多情苦，一寸还成千万缕。', source: '晏殊《玉楼春》'),
    LoveVerse(text: '月上柳梢头，人约黄昏后。', source: '欧阳修《生查子》'),
    LoveVerse(text: '人生自是有情痴，此恨不关风与月。', source: '欧阳修《玉楼春》'),
    LoveVerse(text: '我住长江头，君住长江尾。', source: '李之仪《卜算子》'),
    LoveVerse(text: '山盟虽在，锦书难托。', source: '陆游《钗头凤》'),
    LoveVerse(text: '春如旧，人空瘦，泪痕红浥鲛绡透。', source: '陆游《钗头凤》'),
    LoveVerse(text: '世情薄，人情恶，雨送黄昏花易落。', source: '唐琬《钗头凤》'),
    // 元明清
    LoveVerse(text: '人生若只如初见，何事秋风悲画扇。', source: '纳兰性德《木兰花令》'),
    LoveVerse(text: '等闲变却故人心，却道故人心易变。', source: '纳兰性德《木兰花令》'),
    LoveVerse(text: '若似月轮终皎洁，不辞冰雪为卿热。', source: '纳兰性德《蝶恋花》'),
    LoveVerse(text: '一生一代一双人，争教两处销魂。', source: '纳兰性德《画堂春》'),
    LoveVerse(text: '相思相望不相亲，天为谁春。', source: '纳兰性德《画堂春》'),
    LoveVerse(text: '赌书消得泼茶香，当时只道是寻常。', source: '纳兰性德《浣溪沙》'),
    LoveVerse(text: '谁念西风独自凉，萧萧黄叶闭疏窗。', source: '纳兰性德《浣溪沙》'),
    LoveVerse(text: '换我心，为你心，始知相忆深。', source: '顾夐《诉衷情》'),
    LoveVerse(text: '问世间情为何物，直教生死相许。', source: '元好问《摸鱼儿》'),
    LoveVerse(text: '君住长江头，我住长江尾，日日思君不见君。', source: '李之仪《卜算子》'),
    // 短句·可作副标题或点缀
    LoveVerse(text: '两心知。', source: '白居易'),
    LoveVerse(text: '与君初相识，犹如故人归。', source: '佚名'),
    LoveVerse(text: '一世一双人。', source: '化用纳兰词'),
    LoveVerse(text: '岁岁长相见。', source: '冯延巳《长命女》'),
    LoveVerse(text: '一往情深深几许。', source: '纳兰性德'),
    LoveVerse(text: '世间安得双全法，不负如来不负卿。', source: '仓央嘉措'),
    LoveVerse(text: '但使两心相照，无灯无月何妨。', source: '周炼霞'),
    LoveVerse(text: '今岁东风，与君同。', source: '化用'),
    // 现代诗
    LoveVerse(text: '我将于茫茫人海中访我唯一灵魂之伴侣。', source: '徐志摩'),
    LoveVerse(text: '得之我幸，不得我命。', source: '徐志摩'),
    LoveVerse(text: '你记得也好，最好你忘掉。', source: '徐志摩《偶然》'),
    LoveVerse(text: '我是天空里的一片云，偶尔投影在你的波心。', source: '徐志摩《偶然》'),
    LoveVerse(text: '如何让你遇见我，在我最美丽的时刻。', source: '席慕蓉《一棵开花的树》'),
    LoveVerse(text: '在你身后落了一地的，朋友啊，那不是花瓣，是我凋零的心。', source: '席慕蓉《一棵开花的树》'),
    LoveVerse(text: '所有的结局都已写好，所有的泪水也都已启程。', source: '席慕蓉《青春》'),
    LoveVerse(text: '在年轻的时候，如果你爱上了一个人，请你一定要温柔地对待他。', source: '席慕蓉'),
    LoveVerse(text: '草在结它的种子，风在摇它的叶子，我们站着，不说话，就十分美好。', source: '顾城《门前》'),
    LoveVerse(text: '你，一会看我，一会看云。我觉得，你看我时很远，你看云时很近。', source: '顾城《远和近》'),
    LoveVerse(text: '黑夜给了我黑色的眼睛，我却用它寻找光明。', source: '顾城《一代人》'),
    LoveVerse(text: '我们站着，不说话，就十分美好。', source: '顾城'),
    LoveVerse(text: '我如果爱你——绝不像攀援的凌霄花。', source: '舒婷《致橡树》'),
    LoveVerse(text: '我们分担寒潮、风雷、霹雳；我们共享雾霭、流岚、虹霓。', source: '舒婷《致橡树》'),
    LoveVerse(text: '仿佛永远分离，却又终身相依。', source: '舒婷《致橡树》'),
    LoveVerse(text: '不仅爱你伟岸的身躯，也爱你坚持的位置，足下的土地。', source: '舒婷《致橡树》'),
    LoveVerse(text: '你是我今生未完成的歌，唱不到结局却又难以割舍。', source: '舒婷'),
    LoveVerse(text: '我达达的马蹄是美丽的错误，我不是归人，是个过客。', source: '郑愁予《错误》'),
    LoveVerse(text: '我打江南走过，那等在季节里的容颜如莲花的开落。', source: '郑愁予《错误》'),
    LoveVerse(text: '从明天起，和每一个亲人通信，告诉他们我的幸福。', source: '海子《面朝大海，春暖花开》'),
    LoveVerse(text: '愿你有一个灿烂的前程，愿你有情人终成眷属。', source: '海子《面朝大海，春暖花开》'),
    LoveVerse(text: '今夜我不关心人类，我只想你。', source: '海子《日记》'),
    LoveVerse(text: '你来人间一趟，你要看看太阳，和你的心上人，一起走在街上。', source: '海子'),
    LoveVerse(text: '不要问我心里有没有你，我余光中都是你。', source: '余光中'),
    LoveVerse(text: '若逢新雪初霁，满月当空，下面平铺着皓影，上面流转着亮银。', source: '余光中'),
    LoveVerse(text: '你带笑地向我走来，月色和雪色之间，你是第三种绝色。', source: '余光中《绝色》'),
    LoveVerse(text: '你是我温暖的手套，冰冷的啤酒，带着阳光味道的衬衫，日复一日的梦想。', source: '廖一梅'),
    LoveVerse(text: '你是我的半截的诗，不许别人更改一个字。', source: '海子'),
    LoveVerse(text: '人间值得，你更值得。', source: '佚名'),
    LoveVerse(text: '山河远阔，人间烟火，无一是你，无一不是你。', source: '春和'),
    LoveVerse(text: '愿有岁月可回首，且以深情共白头。', source: '佚名'),
    LoveVerse(text: '一屋两人三餐四季。', source: '佚名'),
    LoveVerse(text: '斯人若彩虹，遇上方知有。', source: '韩寒《怦然心动》'),
    LoveVerse(text: '你是我这一生，等了半世未拆的礼物。', source: '林夕'),
    LoveVerse(text: '在有生的瞬间能遇到你，竟花光所有运气。', source: '林夕'),
    LoveVerse(text: '你是我心内的一首歌，心间开启花一朵。', source: '流行'),
    LoveVerse(text: '春风再美也比不上你的笑，没见过的人不会明了。', source: '李宗盛'),
    LoveVerse(text: '我遇见你，我记得你，这座城市天生就适合恋爱，你天生就适合我的灵魂。', source: '杜拉斯'),
  ];

  /// 按日期种子取一句，同一天内不变，不同天不同（有惊喜）
  static LoveVerse getVerseOfDay(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    return all[seed % all.length];
  }

  /// 完全随机一句，每次调用都可能不同
  static LoveVerse getRandomVerse([int? seed]) {
    final index = seed ?? DateTime.now().millisecondsSinceEpoch;
    return all[index % all.length];
  }

  /// 首页主标题池：每次进入随机/按日切换，有惊喜
  static const List<String> homeGreetings = [
    '君归矣',
    '良人归矣',
    '卿归矣',
    '伊人归矣',
    '君至矣',
    '与君见',
  ];

  /// 按日取首页主标题，同一天一致
  static String getGreetingOfDay(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    return homeGreetings[seed % homeGreetings.length];
  }

  /// 入口区标题池：一念即达 / 心诺即赴 等，按日切换
  static const List<String> sectionTitles = [
    '一念即达',
    '心诺即赴',
    '与君共赴',
    '一念即至',
    '咫尺可达',
  ];

  static String getSectionTitleOfDay(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    return sectionTitles[seed % sectionTitles.length];
  }

  /// 按日取短句副标题
  static LoveVerse getShortVerseOfDay(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    return shortForSubtitle[seed % shortForSubtitle.length];
  }

  /// 完全随机短句（每次进入可不同）
  static LoveVerse getRandomShortVerse([int? seed]) {
    final index = seed ?? DateTime.now().millisecondsSinceEpoch;
    return shortForSubtitle[index % shortForSubtitle.length];
  }

  /// 短句列表：适合做副标题、空状态提示（古典 + 现代）
  static const List<LoveVerse> shortForSubtitle = [
    LoveVerse(text: '两心相知，一事一诺', source: ''),
    LoveVerse(text: '与君共赴，新岁同归', source: ''),
    LoveVerse(text: '一念即达，心诺即赴', source: ''),
    LoveVerse(text: '君归矣，心诺矣', source: ''),
    LoveVerse(text: '所谓伊人，在水一方', source: '《诗经》'),
    LoveVerse(text: '执子之手，与子偕老', source: '《诗经》'),
    LoveVerse(text: '今夕何夕，见此良人', source: '《诗经》'),
    LoveVerse(text: '一日不见，如三秋兮', source: '《诗经》'),
    LoveVerse(text: '金风玉露，胜却人间', source: '秦观'),
    LoveVerse(text: '只愿君心似我心', source: '李之仪'),
    LoveVerse(text: '岁岁长相见', source: '冯延巳'),
    LoveVerse(text: '一生一代一双人', source: '纳兰性德'),
    LoveVerse(text: '心有灵犀一点通', source: '李商隐'),
    LoveVerse(text: '此物最相思', source: '王维'),
    LoveVerse(text: '与君初相识，犹如故人归', source: ''),
    LoveVerse(text: '我们站着，就十分美好', source: '顾城'),
    LoveVerse(text: '得之我幸，不得我命', source: '徐志摩'),
    LoveVerse(text: '斯人若彩虹，遇上方知有', source: ''),
    LoveVerse(text: '愿有岁月可回首，且以深情共白头', source: ''),
    LoveVerse(text: '一屋两人三餐四季', source: ''),
    LoveVerse(text: '我余光中都是你', source: '余光中'),
    LoveVerse(text: '你是第三种绝色', source: '余光中'),
  ];
}
