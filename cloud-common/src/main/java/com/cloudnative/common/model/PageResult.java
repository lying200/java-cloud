package com.cloudnative.common.model;

import lombok.Data;
import lombok.experimental.Accessors;

import java.util.List;

@Data
@Accessors(chain = true)
public class PageResult<T> {
    private List<T> records;
    private long total;
    private long page;
    private long size;

    public static <T> PageResult<T> of(List<T> records, long total, long page, long size) {
        return new PageResult<T>()
                .setRecords(records)
                .setTotal(total)
                .setPage(page)
                .setSize(size);
    }
}
