import { defineConfig } from "vite";

export default defineConfig(async () => {
    let visitCount = process.env.VISIT_COUNT;
    if(!visitCount) {
        const res = await fetch("https://api.crc.cloudydaiyz.com/portfolio", {
            method: "POST",
        });
        const resJson = await res.json();

        console.log("Successfully fetched & updated visit count.");
        console.log(res);
        visitCount = resJson.body.count;
    }
    console.log('Visit count: ' + visitCount);

    return {
        define: {
            __VISIT_COUNT__: visitCount,
        },
    };
});