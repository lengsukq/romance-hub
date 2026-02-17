export interface UserInfo {
  userId: number;
  userEmail: string;
  username: string;
  avatar: string;
  lover: string;
  describeBySelf: string;
  score: number;
  registrationTime: string;
}

export interface LoverInfo {
  username: string;
  avatar: string;
  userEmail: string;
  describeBySelf: string;
  score: number;
  registrationTime: string;
}

export interface EditUserInfo {
  username: string;
  avatar: string;
  describeBySelf: string;
}

