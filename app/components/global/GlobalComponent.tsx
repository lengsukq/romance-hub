import { usePathname, useRouter } from "next/navigation";
import { Tab, Tabs } from "@heroui/react";
import { TaskListLeftDropdown, TaskListRightDropdown } from "@/components/global/tasklistdropdown";
import { MyGiftLeftDropdown, MyGiftRightDropdown } from "@/components/global/mygiftdropdown";
import { ReactNode, Key } from "react";

const LeftComponent = (): ReactNode => {
  const pathname = usePathname();
  if (pathname === '/trick' || pathname.startsWith('/trick/postTask') || pathname.startsWith('/trick/taskInfo')) {
    return <TaskListLeftDropdown />;
  }
  if (pathname.startsWith('/trick/gift')) {
    return <MyGiftLeftDropdown />;
  }
  return null;
};

const RightComponent = (): ReactNode => {
  const pathname = usePathname();
  if (pathname === '/trick' || pathname.startsWith('/trick/postTask') || pathname.startsWith('/trick/taskInfo')) {
    return <TaskListRightDropdown />;
  }
  if (pathname.startsWith('/trick/gift')) {
    return <MyGiftRightDropdown />;
  }
  return null;
};

interface TabConfig {
  key: string;
  title: string;
}

interface TabsGroupConfig {
  paths: string[];
  tabs: TabConfig[];
  onSelectionChange: (key: Key) => void;
}

interface TabsComponentProps {
  pathname: string;
}

const SectionTabs = ({ pathname }: TabsComponentProps): ReactNode => {
  const router = useRouter();
  const toPage = (key: Key): void => router.push(key as string);
  const childToPage = (key: Key): void => router.replace(key as string);

  const tabsConfig: TabsGroupConfig[] = [
    {
      paths: ['/trick', '/trick/postTask', '/trick/taskInfo'],
      tabs: [
        { key: '/trick', title: '心诺' },
        { key: '/trick/postTask', title: '立一诺' },
      ],
      onSelectionChange: toPage,
    },
    {
      paths: ['/trick/gift', '/trick/gift/addGift', '/trick/gift/getList'],
      tabs: [
        { key: '/trick/gift/getList', title: '可兑' },
        { key: '/trick/gift/addGift', title: '上架' },
        { key: '/trick/gift', title: '吾架' },
      ],
      onSelectionChange: childToPage,
    },
    {
      paths: ['/trick/whisper', '/trick/whisper/TAWhisper', '/trick/whisper/myWhisper'],
      tabs: [
        { key: '/trick/whisper/TAWhisper', title: '良人' },
        { key: '/trick/whisper', title: '写私语' },
        { key: '/trick/whisper/myWhisper', title: '吾之' },
      ],
      onSelectionChange: childToPage,
    },
    {
      paths: ['/trick/favourite/taskList', '/trick/favourite/giftList', '/trick/favourite/whisperList'],
      tabs: [
        { key: '/trick/favourite/taskList', title: '心诺' },
        { key: '/trick/favourite/giftList', title: '赠礼' },
        { key: '/trick/favourite/whisperList', title: '私语' },
      ],
      onSelectionChange: childToPage,
    },
  ];

  const config = tabsConfig.find((configItem: TabsGroupConfig) => 
    configItem.paths.includes(pathname)
  );

  if (!config) return null;

  return (
    <Tabs
      selectedKey={pathname}
      key="lg"
      size="md"
      aria-label="Options"
      onSelectionChange={config.onSelectionChange}
    >
      {config.tabs.map((tab: TabConfig) => (
        <Tab key={tab.key} title={tab.title} />
      ))}
    </Tabs>
  );
};

function getMainNavSelectedKey(pathname: string): string {
  if (pathname.startsWith('/trick/gift')) return '/trick/gift';
  if (pathname.startsWith('/trick/whisper')) return '/trick/whisper';
  if (pathname.startsWith('/trick/myInfo') || pathname.startsWith('/trick/config')) return '/trick/myInfo';
  if (pathname.startsWith('/trick/home')) return '/trick/home';
  if (pathname.startsWith('/trick/favourite')) return '/trick/home';
  if (pathname.startsWith('/trick')) return '/trick';
  return '/trick/home';
}

const MAIN_NAV_ROUTE: Record<string, string> = {
  '/trick/home': '/trick/home',
  '/trick': '/trick',
  '/trick/gift': '/trick/gift/getList',
  '/trick/whisper': '/trick/whisper/TAWhisper',
  '/trick/myInfo': '/trick/myInfo',
};

function MainNavTabs({ pathname }: { pathname: string }): ReactNode {
  const router = useRouter();
  const selectedKey = getMainNavSelectedKey(pathname);

  const onSelectionChange = (key: Key): void => {
    const to = MAIN_NAV_ROUTE[key as string];
    if (to) router.push(to);
  };

  return (
    <Tabs
      selectedKey={selectedKey}
      size="md"
      aria-label="Main Navigation"
      onSelectionChange={onSelectionChange}
    >
      <Tab key="/trick/home" title="首页" />
      <Tab key="/trick" title="心诺" />
      <Tab key="/trick/gift" title="赠礼" />
      <Tab key="/trick/whisper" title="私语" />
      <Tab key="/trick/myInfo" title="吾心" />
    </Tabs>
  );
}

function shouldShowSectionTabs(pathname: string): boolean {
  return (
    pathname === '/trick' ||
    pathname.startsWith('/trick/postTask') ||
    pathname.startsWith('/trick/taskInfo') ||
    pathname.startsWith('/trick/gift') ||
    pathname.startsWith('/trick/whisper') ||
    pathname.startsWith('/trick/favourite')
  );
}

export function GlobalComponent() {
    const pathname = usePathname();
    const showSectionRow = shouldShowSectionTabs(pathname);

    return (
        <div className="GlobalComponent bg-gradient-to-b from-white to-default-200 flex flex-col w-full justify-center fixed bottom-0 pb-3 pt-3 z-10 items-center">
            <div className="w-full flex justify-center px-3">
              <MainNavTabs pathname={pathname} />
            </div>
            {showSectionRow && (
              <div className="w-full flex flex-wrap gap-3 justify-center items-center px-3 pt-2">
                <LeftComponent />
                <SectionTabs pathname={pathname} />
                <RightComponent />
              </div>
            )}
        </div>
    );
}