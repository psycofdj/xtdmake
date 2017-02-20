<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" omit-xml-declaration="yes" />
  <xsl:template match="/">
    <xsl:variable name="total"   select="count(./testResults/httpSample) + count(./testResults/sample)"/>
    <xsl:variable name="success" select="count(./testResults/httpSample[@s='true']) + count(./testResults/sample[@s='true'])"/>
    <xsl:variable name="failure" select="count(./testResults/httpSample[@s='false']) + count(./testResults/sample[@s='false'])"/>
    <xsl:variable name="percent" select="format-number(($success * 100) div $total, '##.##')"/>
    <xsl:variable name="status">
      <xsl:choose>
        <xsl:when test="$failure = 0">success</xsl:when>
        <xsl:otherwise>failure</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
{
  "status": "<xsl:value-of select="$status"/>",
  "data": {
    "success": <xsl:value-of select="$success"/>,
    "failures": <xsl:value-of select="$failure"/>
  },
  "label": "<xsl:value-of select="$failure"/>",
  "graphs": [
    {
      "data": {
        "labels": [],
        "datasets": [
          {
            "borderColor": "rgba(51, 204, 51, 0.5)",
            "pointBorderColor": "rgba(31, 122, 31, 1)",
            "yAxisID": "absolute",
            "label": "nb failures",
            "backgroundColor": "rgba(51, 204, 51, 0)",
            "pointBackgroundColor": "rgba(31, 122, 31, 1)",
            "data": "%(failures)d"
          },
          {
            "borderColor": "rgba(179, 0, 0, 0.5)",
            "pointBorderColor": "rgba(102, 0, 0, 1)",
            "yAxisID": "absolute",
            "label": "nb success",
            "backgroundColor": "rgba(179, 0, 0, 0)",
            "pointBackgroundColor": "rgba(102, 0, 0, 1)",
            "data": "%(success)d"
          }
        ]
      },
      "type": "line",
      "options": {
        "scales": {
          "xAxes": [
            {
              "ticks": {
                "fontSize": 12,
                "minRotation": 80
              }
            }
          ],
          "yAxes": [
            {
              "position": "left",
              "ticks": {
                "fontSize": 24,
                "beginAtZero": true
              },
              "type": "linear",
              "id": "absolute",
              "display": true
            }
          ]
        },
        "title": {
          "text": "jmeter",
          "display": true
        }
      }
    }
  ]
}
  </xsl:template>
</xsl:stylesheet>
