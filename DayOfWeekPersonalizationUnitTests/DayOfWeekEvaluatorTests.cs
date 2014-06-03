using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using DayOfWeekPersonalization;
using Telerik.Sitefinity.Personalization;
using Telerik.Sitefinity.Personalization.Impl;

namespace DayOfWeekPersonalizationUnitTests
{
    [TestClass]
    public class DayOfWeekEvaluatorTests
    {
        [TestMethod]
        public void TestDayOfWeekEvaluatorReturnsTrueWhenDateTimeIsMondayAndSettingsIsMonday()
        {
            // arrange
            DateTime mondayDate = new DateTime(2014, 6, 2); 
            string mondayString = ((int)mondayDate.DayOfWeek).ToString();
            DayOfWeekEvaluator dayOfWeekEvaluator = new DayOfWeekEvaluator();

            // act
            dayOfWeekEvaluator.CurrentDateTime = mondayDate;
            bool expectedResult = dayOfWeekEvaluator.IsMatch(mondayString, new PersonalizationTestContext());

            // assert
            Assert.IsTrue(expectedResult);
        }

        [TestMethod]
        public void TestDayOfWeekEvaluatorReturnsFalseWhenDateTimeIsMondayAndSettingsIsTuesday()
        {
            // arrange
            DateTime mondayDate = new DateTime(2014, 6, 2);
            DateTime tuesdayDate = mondayDate.AddDays(1);
            string tuesdayString = ((int)tuesdayDate.DayOfWeek).ToString();
            DayOfWeekEvaluator dayOfWeekEvaluator = new DayOfWeekEvaluator();

            // act
            dayOfWeekEvaluator.CurrentDateTime = mondayDate;
            bool expectedResult = dayOfWeekEvaluator.IsMatch(tuesdayString, new PersonalizationTestContext());

            // assert
            Assert.IsFalse(expectedResult);
        }
    }
}
