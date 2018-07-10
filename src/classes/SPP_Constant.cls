/**
 * SPP_Constant.
 * @author Mulodo VN
 * @version 1.0
 * @Description: Constant class
 */

public with sharing class SPP_Constant {
	public static final Long URL_EXPIRE_TIME = 259200000; //72 hours in miliseconds
    public static final Integer ID_DIGIT_COUNT = 32;	
    public static final Integer UNLOCK_PERIOR = 3600000; // 1 hour in miliseconds
    public static final Integer RESET_PASS_MONTH = 6; // Reset password after 6 months
    public static final String EMPTY_PASS_URL_PAR = 'a';
    public static final String RESET_PASS_URL_PAR = 'r';

    //Message to show on page
    public static final String MSG_EMAIL_SENT = '新しいパスワードが送られました。メールを確認ください。';
    public static final String MSG_USERNAME_NOT_FOUND = '入力内容と一致するユーザ名が見つかりません。ユーザ名が username@company.com などのメールアドレスであることを確認してください。';
    public static final String MSG_EMPTY_PASS = 'パスワードを入力してください。';
	public static final String MSG_USER_NOT_FOUND = 'ユーザ名とパスワードを確認してください。それでもログインできない場合は、Salesforce システム管理者にお問い合わせください。';
	public static final String MSG_WRONG_USER_TYPE = 'ユーザータイプが不正です。自分のサイトをご確認ください。';
	public static final String MSG_USER_LOCKED = 'このアカウントはロックされています。ロックを解除するには、Salesforce システム管理者にお問い合わせください。';
	public static final String MSG_ERROR_OCCURRED = '想定外のエラーが発生しました。システム管理者に連絡してください。';
    public static final String MSG_AUTO_RESET_PASS = '前回の変更から6ヶ月が経過しましたので、パスワードの変更をお願いします。';

    //Log record
    public static final String LOG_LOGOUT = ': ログアウト';
    public static final String LOG_CHANGE_PASS = ': パスワードが変更されました';
    public static final String LOG_CREATE_USER = ': アカウントが作成されました';
    public static final String LOG_SESSION_TIMEOUT = ': セッションタイムアウト';
    public static final String LOG_RESET_PASS = ': パスワードリセットメール送信';
    public static final String LOG_USER_NOT_FOUND = ': ユーザーが見つかりません';
    public static final String LOG_USER_LOCKED = ': ロックされている状態でログインする。';
    public static final String LOG_USER_INVALID = ': ユーザーが有効ではありません';
    public static final String LOG_LOCKED = ': ロックされました';
    public static final String LOG_LOGIN_FAILED = ': ログイン失敗';
    public static final String LOG_LOGIN_OK = ': ログイン成功';
    public static final String LOG_PASS_UPDATED = ': パスワードの変更に成功しました。';
    public static final String LOG_PROFILE_UPDATED = ': プロファイルの編集に成功しました。';
}