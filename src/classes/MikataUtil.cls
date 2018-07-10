// CLOUD PAYMENT
// 経理のミカタ
// ユーティリティ
public with sharing class MikataUtil {
    // コンストラクタ
    private MikataUtil() {}

    // 数値を返す
    public static Integer toInteger(Decimal dc) {
        if (dc != null) {
            return Integer.valueOf(dc);
        } else {
            return null;
        }
    }

    // 数値を返す
    public static Integer toInteger(String s) {
        if (String.isNotBlank(s)) {
            return Integer.valueOf(s);
        } else {
            return null;
        }
    }

    // 日付文字列を返す
    public static String dateString(Date dt) {
        if (dt != null) {
            return Datetime.newInstance(dt.year(), dt.month(), dt.day()).format('yyyy/MM/dd');
        } else {
            return null;
        }
    }
}