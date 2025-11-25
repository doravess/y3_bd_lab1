using System;
using System.Data;

namespace StoreApp_lab1_bd.Data
{
    public static class DataReaderExtensions
    {
        public static bool HasColumn(this IDataRecord record, string columnName)
        {
            for (int i = 0; i < record.FieldCount; i++)
            {
                if (record.GetName(i).Equals(columnName, StringComparison.InvariantCultureIgnoreCase))
                    return true;
            }

            return false;
        }
    }
}
